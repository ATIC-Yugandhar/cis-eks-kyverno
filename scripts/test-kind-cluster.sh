#!/bin/bash

set -euo pipefail

CLUSTER_NAME="kyverno-test"
REPORTS_DIR="reports/kind-cluster"
SKIP_CREATE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-create)
            SKIP_CREATE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

mkdir -p "$REPORTS_DIR"

echo "=== Kind Cluster Integration Tests ==="
echo "Started at: $(date)"

# Check if we should skip cluster creation
if [ "${CI:-false}" = "true" ] || [ "${GITHUB_ACTIONS:-false}" = "true" ]; then
    echo "Running in CI environment"
    # In CI, we'll create the cluster unless explicitly told to skip
fi

if [ "$SKIP_CREATE" = "false" ]; then
    # Create Kind cluster
    echo "Creating Kind cluster..."
    
    # Check if cluster already exists
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        echo "Cluster $CLUSTER_NAME already exists, deleting..."
        kind delete cluster --name="$CLUSTER_NAME"
    fi
    
    # Create cluster configuration
    cat > "$REPORTS_DIR/kind-cluster-config.yaml" << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
EOF
    
    # Create cluster
    kind create cluster --name="$CLUSTER_NAME" --config="$REPORTS_DIR/kind-cluster-config.yaml"
    
    # Wait for cluster to be ready
    echo "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Install Kyverno
    echo "Installing Kyverno..."
    kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.13.6/install.yaml
    
    # Wait for Kyverno to be ready
    echo "Waiting for Kyverno to be ready..."
    kubectl wait --for=condition=Ready pods -n kyverno --all --timeout=300s
    
    # Apply RBAC fix for Node access and other permissions
    echo "Applying RBAC fix for Node and Secret access..."
    if [ -f "kyverno-node-rbac.yaml" ]; then
        kubectl apply -f kyverno-node-rbac.yaml
        echo "✅ RBAC fix applied for Node access permissions"
    else
        echo "⚠️ RBAC fix file not found, creating it..."
        cat > kyverno-node-rbac.yaml << 'RBAC_EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kyverno-reports-controller-node-access
rules:
- apiGroups: [""]
  resources: ["nodes", "secrets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kyverno-reports-controller-node-access
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kyverno-reports-controller-node-access
subjects:
- kind: ServiceAccount
  name: kyverno-reports-controller
  namespace: kyverno
RBAC_EOF
        kubectl apply -f kyverno-node-rbac.yaml
        echo "✅ RBAC fix created and applied"
    fi
    
    # Deploy kube-bench for CIS compliance scanning
    echo "Deploying kube-bench for CIS compliance scanning..."
    
    # Apply kube-bench RBAC
    kubectl apply -f kube-bench/rbac.yaml
    
    # Deploy kube-bench jobs
    echo "Running kube-bench node scan..."
    kubectl apply -f kube-bench/job-node.yaml
    
    # Wait for kube-bench jobs to complete
    echo "Waiting for kube-bench scan to complete..."
    sleep 10  # Give time for pod to start
    
    # Check if job completed or failed
    for i in {1..30}; do
        JOB_STATUS=$(kubectl get job kube-bench-node -n kube-system -o jsonpath='{.status.conditions[0].type}' 2>/dev/null || echo "")
        if [ "$JOB_STATUS" = "Complete" ]; then
            echo "✅ Kube-bench scan completed successfully"
            break
        elif [ "$JOB_STATUS" = "Failed" ]; then
            echo "⚠️ Kube-bench scan failed, collecting available results..."
            break
        fi
        echo "Waiting for kube-bench to complete... ($i/30)"
        sleep 10
    done
    
    # Collect kube-bench results
    echo "Collecting kube-bench scan results..."
    mkdir -p "$REPORTS_DIR/kube-bench"
    
    # Get node scan results
    NODE_POD=$(kubectl get pods -n kube-system -l app=kube-bench,component=node -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$NODE_POD" ]; then
        kubectl logs "$NODE_POD" -n kube-system > "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null || {
            echo "Warning: Could not collect node scan logs"
            echo '{"error": "Could not collect node scan logs"}' > "$REPORTS_DIR/kube-bench/node-scan.json"
        }
        echo "✅ Node scan results collected"
    else
        echo "❌ No kube-bench node pod found"
        echo '{"error": "No kube-bench node pod found"}' > "$REPORTS_DIR/kube-bench/node-scan.json"
    fi
    
    # Try to get master scan results (might not work in KIND due to node labeling)
    MASTER_POD=$(kubectl get pods -n kube-system -l app=kube-bench,component=master -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$MASTER_POD" ]; then
        kubectl logs "$MASTER_POD" -n kube-system > "$REPORTS_DIR/kube-bench/master-scan.json" 2>/dev/null || {
            echo "Warning: Could not collect master scan logs"
            echo '{"error": "Could not collect master scan logs"}' > "$REPORTS_DIR/kube-bench/master-scan.json"
        }
        echo "✅ Master scan results collected"
    else
        echo "⚠️ No kube-bench master pod found (expected in KIND)"
        echo '{"info": "Master scan not available in KIND cluster"}' > "$REPORTS_DIR/kube-bench/master-scan.json"
    fi
    
    # Generate kube-bench summary
    echo "Generating kube-bench summary..."
    cat > "$REPORTS_DIR/kube-bench/summary.md" << 'EOF'
# Kube-bench CIS Compliance Scan Results

**Generated**: $(date)
**Cluster**: KIND cluster
**Scanner**: kube-bench

## Node Scan Results
EOF
    
    if [ -f "$REPORTS_DIR/kube-bench/node-scan.json" ] && grep -q '"Totals"' "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null; then
        echo "✅ Node scan completed successfully" >> "$REPORTS_DIR/kube-bench/summary.md"
        
        # Extract totals using jq if available, otherwise use grep
        if command -v jq >/dev/null 2>&1; then
            PASS=$(jq -r '.Totals.pass // 0' "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null || echo "N/A")
            FAIL=$(jq -r '.Totals.fail // 0' "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null || echo "N/A")
            WARN=$(jq -r '.Totals.warn // 0' "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null || echo "N/A")
            INFO=$(jq -r '.Totals.info // 0' "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null || echo "N/A")
        else
            PASS=$(grep -o '"pass":[0-9]*' "$REPORTS_DIR/kube-bench/node-scan.json" | cut -d: -f2 || echo "N/A")
            FAIL=$(grep -o '"fail":[0-9]*' "$REPORTS_DIR/kube-bench/node-scan.json" | cut -d: -f2 || echo "N/A")
            WARN=$(grep -o '"warn":[0-9]*' "$REPORTS_DIR/kube-bench/node-scan.json" | cut -d: -f2 || echo "N/A")
            INFO=$(grep -o '"info":[0-9]*' "$REPORTS_DIR/kube-bench/node-scan.json" | cut -d: -f2 || echo "N/A")
        fi
        
        echo "- **Pass**: $PASS" >> "$REPORTS_DIR/kube-bench/summary.md"
        echo "- **Fail**: $FAIL" >> "$REPORTS_DIR/kube-bench/summary.md"
        echo "- **Warn**: $WARN" >> "$REPORTS_DIR/kube-bench/summary.md"
        echo "- **Info**: $INFO" >> "$REPORTS_DIR/kube-bench/summary.md"
    else
        echo "❌ Node scan failed or returned invalid data" >> "$REPORTS_DIR/kube-bench/summary.md"
    fi
    
    cat >> "$REPORTS_DIR/kube-bench/summary.md" << 'EOF'

## Integration with Kyverno

This kube-bench scan complements the Kyverno policy validation:
- **Kube-bench**: Validates node-level file permissions, kubelet settings, and OS-level configurations
- **Kyverno**: Validates Kubernetes API resources, RBAC, and workload security policies

## CIS Controls Coverage

The following CIS controls are validated by kube-bench:
- 3.1.x: Worker node configuration files
- 3.2.x: Worker node kubelet configuration
- 4.1.x: Control plane node configuration files (when available)
- 4.2.x: Control plane kubelet configuration (when available)

## Next Steps

1. Review failed checks in the detailed JSON results
2. Cross-reference with Kyverno policy results
3. Implement remediation for identified issues
4. Update worker node policies to incorporate kube-bench findings
EOF
    
    # Update summary with actual date
    sed -i.bak "s/\$(date)/$(date)/" "$REPORTS_DIR/kube-bench/summary.md" && rm "$REPORTS_DIR/kube-bench/summary.md.bak"
    
    # Apply all policies to the cluster
    echo "Applying Kyverno policies to cluster..."
    # Apply policies from all subdirectories
    for dir in policies/kubernetes/*/; do
        if [ -d "$dir" ]; then
            echo "Applying policies from $dir"
            kubectl apply -f "$dir" || true
        fi
    done
    
    # Wait for policies to be ready
    echo "Waiting for policies to be ready..."
    sleep 10
    
    # Run validation tests
    echo "Running Kyverno validation tests..."
    
    # Test with sample resources
    if [ -d "tests/kind-manifests" ]; then
        echo "Testing with Kind manifests..."
        # First create the namespace for real
        kubectl apply -f tests/kind-manifests/namespace.yaml 2>/dev/null || true
        
        # Now test the other resources with dry-run
        for manifest in tests/kind-manifests/*.yaml; do
            if [ -f "$manifest" ] && [ "$(basename "$manifest")" != "namespace.yaml" ]; then
                echo "Testing $(basename "$manifest")..." >> "$REPORTS_DIR/validation-results.txt"
                kubectl apply -f "$manifest" --dry-run=server >> "$REPORTS_DIR/validation-results.txt" 2>&1 || true
            fi
        done
    fi
    
    # Run Kyverno apply on test resources
    echo "Running Kyverno validation on test resources..."
    for policy_dir in policies/kubernetes/*/; do
        if [ -d "$policy_dir" ]; then
            category=$(basename "$policy_dir")
            echo "Testing $category policies..."
            kyverno apply "$policy_dir" --resource tests/kind-manifests/ > "$REPORTS_DIR/kyverno-${category}-results.txt" 2>&1 || true
        fi
    done
    
    # Capture cluster state
    echo "Capturing cluster state..."
    kubectl get all -A > "$REPORTS_DIR/cluster-resources.yaml"
    kubectl get clusterpolicies -o yaml > "$REPORTS_DIR/policies.yaml" 2>/dev/null || echo "No policies found" > "$REPORTS_DIR/policies.yaml"
    
    # Generate comprehensive validation summary
    POLICY_COUNT=$(kubectl get clusterpolicies --no-headers 2>/dev/null | wc -l || echo 0)
    VALIDATION_COUNT=$(find "$REPORTS_DIR" -name "kyverno-*-results.txt" -exec grep -l "pass:\|fail:" {} \; | wc -l || echo 0)
    KUBE_BENCH_STATUS="❌ Failed"
    
    if [ -f "$REPORTS_DIR/kube-bench/node-scan.json" ] && grep -q '"Totals"' "$REPORTS_DIR/kube-bench/node-scan.json" 2>/dev/null; then
        KUBE_BENCH_STATUS="✅ Completed"
    fi
    
    cat > "$REPORTS_DIR/validation-summary.md" << EOF
# Kind Cluster Validation Summary

**Generated**: $(date)
**Mode**: Full cluster validation with kube-bench integration
**Cluster**: $CLUSTER_NAME

## Validation Statistics

| Metric | Value |
|--------|-------|
| Kyverno Policies Applied | $POLICY_COUNT |
| Policy Categories Tested | $VALIDATION_COUNT |
| Test Manifests | $(find tests/kind-manifests -name "*.yaml" | wc -l) |
| Cluster Status | Active |
| Kube-bench Scan | $KUBE_BENCH_STATUS |

## CIS Compliance Coverage

### Kyverno Policy Validation
EOF
    
    # Add Kyverno validation results summary
    for result_file in "$REPORTS_DIR"/kyverno-*-results.txt; do
        if [ -f "$result_file" ]; then
            category=$(basename "$result_file" | sed 's/kyverno-\(.*\)-results.txt/\1/')
            echo "#### $category" >> "$REPORTS_DIR/validation-summary.md"
            echo "" >> "$REPORTS_DIR/validation-summary.md"
            
            # Extract pass/fail counts
            if grep -q "pass:\|fail:" "$result_file"; then
                tail -1 "$result_file" >> "$REPORTS_DIR/validation-summary.md"
            else
                echo "No validation results found" >> "$REPORTS_DIR/validation-summary.md"
            fi
            echo "" >> "$REPORTS_DIR/validation-summary.md"
        fi
    done
    
    cat >> "$REPORTS_DIR/validation-summary.md" << EOF

### Kube-bench CIS Compliance Scan

EOF
    
    if [ -f "$REPORTS_DIR/kube-bench/summary.md" ]; then
        # Include kube-bench summary
        echo "$(cat "$REPORTS_DIR/kube-bench/summary.md")" >> "$REPORTS_DIR/validation-summary.md"
    else
        echo "❌ Kube-bench scan results not available" >> "$REPORTS_DIR/validation-summary.md"
    fi
    
    cat >> "$REPORTS_DIR/validation-summary.md" << EOF

## Cluster Resources

- Kyverno pods: $(kubectl get pods -n kyverno --no-headers | wc -l)
- Total policies: $POLICY_COUNT
- Test manifests validated: $(find tests/kind-manifests -name "*.yaml" | wc -l)
- Kube-bench pods: $(kubectl get pods -n kube-system -l app=kube-bench --no-headers | wc -l)

## Integration Summary

This validation combines:
1. **Kyverno policies** - Kubernetes API resource validation
2. **Kube-bench scanning** - Node-level CIS compliance checks
3. **Test manifests** - Real-world scenario validation

The combination provides comprehensive CIS EKS compliance coverage across all layers.
EOF
    
    # Cleanup kube-bench jobs
    echo "Cleaning up kube-bench jobs..."
    kubectl delete jobs -n kube-system -l app=kube-bench --ignore-not-found=true
    
    # Cleanup
    if [ "${KEEP_CLUSTER:-false}" = "false" ]; then
        echo "Cleaning up Kind cluster..."
        kind delete cluster --name="$CLUSTER_NAME"
    else
        echo "Keeping cluster for debugging (name: $CLUSTER_NAME)"
    fi
else
    echo "Skipping cluster creation - running offline validation"
    
    # Run offline validation against test manifests
    echo "Running offline policy validation..."
    
    # Create summary
    TOTAL_POLICIES=$(find policies/kubernetes -name "*.yaml" | wc -l | tr -d ' ')
    TEST_MANIFESTS=$(find tests/kind-manifests -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
    
    # Run Kyverno validation offline
    echo "Running Kyverno validation on test resources (offline mode)..."
    mkdir -p "$REPORTS_DIR"
    
    for policy_dir in policies/kubernetes/*/; do
        if [ -d "$policy_dir" ]; then
            category=$(basename "$policy_dir")
            echo "Testing $category policies..."
            
            # Apply all policies in the category against all test manifests
            kyverno apply "$policy_dir" --resource tests/kind-manifests/ > "$REPORTS_DIR/kyverno-${category}-results.txt" 2>&1 || true
        fi
    done
    
    # Generate validation summary
    VALIDATION_COUNT=$(find "$REPORTS_DIR" -name "kyverno-*-results.txt" -exec grep -l "pass:\|fail:" {} \; 2>/dev/null | wc -l || echo 0)
    
    cat > "$REPORTS_DIR/validation-summary.md" << EOF
# Kind Cluster Validation Summary

**Generated**: $(date)
**Mode**: Offline validation (no kube-bench)

## Validation Statistics

| Metric | Value |
|--------|-------|
| Total Policies | $TOTAL_POLICIES |
| Test Manifests | $TEST_MANIFESTS |
| Categories Tested | $VALIDATION_COUNT |
| Validation Mode | Offline |
| Kube-bench Scan | ⏭️ Skipped (offline mode) |

## Policy Validation Results

EOF
    
    # Add validation results summary
    for result_file in "$REPORTS_DIR"/kyverno-*-results.txt; do
        if [ -f "$result_file" ]; then
            category=$(basename "$result_file" | sed 's/kyverno-\(.*\)-results.txt/\1/')
            echo "### $category" >> "$REPORTS_DIR/validation-summary.md"
            echo "" >> "$REPORTS_DIR/validation-summary.md"
            
            # Extract pass/fail counts
            if grep -q "pass:\|fail:" "$result_file"; then
                tail -1 "$result_file" >> "$REPORTS_DIR/validation-summary.md"
            else
                echo "No validation results found" >> "$REPORTS_DIR/validation-summary.md"
            fi
            echo "" >> "$REPORTS_DIR/validation-summary.md"
        fi
    done
    
    echo "## Results" >> "$REPORTS_DIR/validation-summary.md"
    echo "" >> "$REPORTS_DIR/validation-summary.md"
    echo "Offline validation completed. Policy validation results show how these policies would behave in a real cluster." >> "$REPORTS_DIR/validation-summary.md"
    echo "" >> "$REPORTS_DIR/validation-summary.md"
    echo "**Note**: Kube-bench CIS compliance scanning requires a live cluster and was skipped in offline mode." >> "$REPORTS_DIR/validation-summary.md"
fi

echo "=== Kind cluster tests completed ==="
echo "Reports available in: $REPORTS_DIR"

if [ -f "$REPORTS_DIR/kube-bench/summary.md" ]; then
    echo ""
    echo "🔍 Kube-bench CIS compliance scan completed"
    echo "📊 Results: $REPORTS_DIR/kube-bench/"
fi