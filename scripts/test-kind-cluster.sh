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
    
    # Apply RBAC fix for Node access
    echo "Applying RBAC fix for Node access..."
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
  resources: ["nodes"]
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
    
    # Apply all policies to the cluster
    echo "Applying policies to cluster..."
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
    echo "Running validation tests..."
    
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
    
    # Generate validation summary
    POLICY_COUNT=$(kubectl get clusterpolicies --no-headers 2>/dev/null | wc -l || echo 0)
    VALIDATION_COUNT=$(find "$REPORTS_DIR" -name "kyverno-*-results.txt" -exec grep -l "pass:\|fail:" {} \; | wc -l || echo 0)
    
    cat > "$REPORTS_DIR/validation-summary.md" << EOF
# Kind Cluster Validation Summary

**Generated**: $(date)
**Mode**: Full cluster validation
**Cluster**: $CLUSTER_NAME

## Validation Statistics

| Metric | Value |
|--------|-------|
| Policies Applied | $POLICY_COUNT |
| Categories Tested | $VALIDATION_COUNT |
| Test Manifests | $(find tests/kind-manifests -name "*.yaml" | wc -l) |
| Cluster Status | Active |

## Policy Application Results

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
    
    echo "## Cluster Resources" >> "$REPORTS_DIR/validation-summary.md"
    echo "" >> "$REPORTS_DIR/validation-summary.md"
    echo "- Kyverno pods: $(kubectl get pods -n kyverno --no-headers | wc -l)" >> "$REPORTS_DIR/validation-summary.md"
    echo "- Total policies: $POLICY_COUNT" >> "$REPORTS_DIR/validation-summary.md"
    echo "- Test manifests validated: $(find tests/kind-manifests -name "*.yaml" | wc -l)" >> "$REPORTS_DIR/validation-summary.md"
    
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
**Mode**: Offline validation

## Validation Statistics

| Metric | Value |
|--------|-------|
| Total Policies | $TOTAL_POLICIES |
| Test Manifests | $TEST_MANIFESTS |
| Categories Tested | $VALIDATION_COUNT |
| Validation Mode | Offline |

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
fi

echo "=== Kind cluster tests completed ==="
echo "Reports available in: $REPORTS_DIR"