#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLUSTER_NAME="cis-eks-kyverno-test"
REPORT_DIR="$PROJECT_ROOT/reports/kind-cluster"
MANIFESTS_DIR="$PROJECT_ROOT/tests/kind-manifests"
POLICIES_DIR="$PROJECT_ROOT/policies/kubernetes"

# Create necessary directories
mkdir -p "$REPORT_DIR" "$MANIFESTS_DIR"

echo -e "${PURPLE}🚀 Starting Kind Cluster CIS EKS Compliance Validation${NC}"
echo -e "${BLUE}📊 Configuration:${NC}"
echo -e "  🔧 Cluster Name: $CLUSTER_NAME"
echo -e "  📁 Report Directory: $REPORT_DIR"
echo -e "  📋 Policies Directory: $POLICIES_DIR"
echo

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}⚙️ [10%] Checking dependencies...${NC}"
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_deps+=("kubectl")
    fi
    
    if ! command -v kyverno &> /dev/null; then
        missing_deps+=("kyverno")
    fi
    
    if ! command -v kind &> /dev/null; then
        echo -e "${YELLOW}Installing kind...${NC}"
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        curl -Lo "$INSTALL_DIR/kind" "https://kind.sigs.k8s.io/dl/latest/kind-${OS}-amd64"
        chmod +x "$INSTALL_DIR/kind"
        export PATH="$INSTALL_DIR:$PATH"
    fi
    
    if ! command -v yq &> /dev/null; then
        echo -e "${YELLOW}Installing yq...${NC}"
        YQ_VERSION="v4.40.5"
        YQ_BINARY="yq_linux_amd64"
        if [[ "$(uname -s)" == "Darwin" ]]; then
            YQ_BINARY="yq_darwin_amd64"
        fi
        INSTALL_DIR_YQ="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR_YQ"
        curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -o "$INSTALL_DIR_YQ/yq"
        chmod +x "$INSTALL_DIR_YQ/yq"
        export PATH="$INSTALL_DIR_YQ:$PATH"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Please install the missing dependencies and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All dependencies satisfied${NC}"
}

# Create kind cluster configuration
create_cluster_config() {
    echo -e "${YELLOW}⚙️ [20%] Creating cluster configuration...${NC}"
    
    cat > "$REPORT_DIR/kind-cluster-config.yaml" << EOF
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: $CLUSTER_NAME
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "kyverno-test=enabled"
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "kyverno-test=enabled"
EOF
    
    echo -e "${GREEN}✅ Cluster configuration created${NC}"
}

# Create test manifests
create_test_manifests() {
    echo -e "${YELLOW}⚙️ [30%] Creating test manifests...${NC}"
    
    # Create namespace
    cat > "$MANIFESTS_DIR/namespace.yaml" << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: kyverno-cis-test
  labels:
    name: kyverno-cis-test
    security.test/enabled: "true"
EOF
    
    # Create compliant pod
    cat > "$MANIFESTS_DIR/compliant-pod.yaml" << EOF
apiVersion: v1
kind: Pod
metadata:
  name: compliant-nginx
  namespace: kyverno-cis-test
  labels:
    app: nginx
    security.test/compliant: "true"
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
  - name: nginx
    image: nginx:1.21-alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    ports:
    - containerPort: 8080
    resources:
      limits:
        memory: "128Mi"
        cpu: "100m"
      requests:
        memory: "64Mi"
        cpu: "50m"
EOF
    
    # Create non-compliant pod for testing
    cat > "$MANIFESTS_DIR/noncompliant-pod.yaml" << EOF
apiVersion: v1
kind: Pod
metadata:
  name: noncompliant-nginx
  namespace: kyverno-cis-test
  labels:
    app: nginx
    security.test/compliant: "false"
spec:
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      privileged: true
      runAsUser: 0
    ports:
    - containerPort: 80
EOF
    
    # Create service account
    cat > "$MANIFESTS_DIR/serviceaccount.yaml" << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-service-account
  namespace: kyverno-cis-test
  annotations:
    security.test/purpose: "cis-validation"
EOF
    
    echo -e "${GREEN}✅ Test manifests created${NC}"
}

# Create and configure cluster
create_cluster() {
    echo -e "${YELLOW}⚙️ [40%] Creating Kind cluster...${NC}"
    
    # Delete existing cluster if it exists
    if kind get clusters | grep -q "^$CLUSTER_NAME$"; then
        echo -e "${YELLOW}Deleting existing cluster $CLUSTER_NAME...${NC}"
        kind delete cluster --name "$CLUSTER_NAME"
    fi
    
    # Create new cluster
    kind create cluster --config "$REPORT_DIR/kind-cluster-config.yaml" --name "$CLUSTER_NAME"
    
    # Wait for cluster to be ready
    echo -e "${YELLOW}Waiting for cluster to be ready...${NC}"
    kubectl cluster-info --context "kind-$CLUSTER_NAME"
    kubectl wait --for=condition=Ready nodes --all --timeout=300s --context "kind-$CLUSTER_NAME"
    
    echo -e "${GREEN}✅ Kind cluster created and ready${NC}"
}

# Install Kyverno
install_kyverno() {
    echo -e "${YELLOW}⚙️ [50%] Installing Kyverno...${NC}"
    
    # Download and install Kyverno
    KYVERNO_VERSION="v1.11.1"
    curl -L "https://github.com/kyverno/kyverno/releases/download/$KYVERNO_VERSION/install.yaml" -o "$REPORT_DIR/kyverno-install.yaml"
    
    kubectl apply -f "$REPORT_DIR/kyverno-install.yaml" --context "kind-$CLUSTER_NAME"
    
    # Wait for Kyverno to be ready
    echo -e "${YELLOW}Waiting for Kyverno to be ready...${NC}"
    kubectl wait --for=condition=Available deployment/kyverno-admission-controller -n kyverno --timeout=300s --context "kind-$CLUSTER_NAME"
    kubectl wait --for=condition=Available deployment/kyverno-background-controller -n kyverno --timeout=300s --context "kind-$CLUSTER_NAME"
    kubectl wait --for=condition=Available deployment/kyverno-cleanup-controller -n kyverno --timeout=300s --context "kind-$CLUSTER_NAME"
    kubectl wait --for=condition=Available deployment/kyverno-reports-controller -n kyverno --timeout=300s --context "kind-$CLUSTER_NAME"
    
    # Wait for CRDs to be established
    kubectl wait --for condition=established --timeout=120s crd/clusterpolicies.kyverno.io --context "kind-$CLUSTER_NAME"
    
    echo -e "${GREEN}✅ Kyverno installed and ready${NC}"
}

# Deploy test applications
deploy_test_apps() {
    echo -e "${YELLOW}⚙️ [60%] Deploying test applications...${NC}"
    
    # Apply manifests
    kubectl apply -f "$MANIFESTS_DIR/namespace.yaml" --context "kind-$CLUSTER_NAME"
    kubectl apply -f "$MANIFESTS_DIR/serviceaccount.yaml" --context "kind-$CLUSTER_NAME"
    kubectl apply -f "$MANIFESTS_DIR/compliant-pod.yaml" --context "kind-$CLUSTER_NAME"
    
    # Try to apply non-compliant pod (should be blocked by policies)
    echo -e "${YELLOW}Testing policy enforcement with non-compliant pod...${NC}"
    set +e
    kubectl apply -f "$MANIFESTS_DIR/noncompliant-pod.yaml" --context "kind-$CLUSTER_NAME" > "$REPORT_DIR/noncompliant-pod-test.log" 2>&1
    NONCOMPLIANT_EXIT_CODE=$?
    set -e
    
    if [ $NONCOMPLIANT_EXIT_CODE -ne 0 ]; then
        echo -e "${GREEN}✅ Non-compliant pod correctly blocked by policies${NC}"
    else
        echo -e "${YELLOW}⚠️ Non-compliant pod was allowed (policies may not be enforcing)${NC}"
    fi
    
    echo -e "${GREEN}✅ Test applications deployed${NC}"
}

# Extract cluster resources
extract_cluster_resources() {
    echo -e "${YELLOW}⚙️ [70%] Extracting cluster resources...${NC}"
    
    # Define resource types to extract
    NAMESPACED_RESOURCES=(
        pods services deployments statefulsets daemonsets jobs cronjobs
        configmaps secrets ingresses networkpolicies persistentvolumeclaims
        serviceaccounts roles rolebindings replicasets endpoints events
        limitranges resourcequotas horizontalpodautoscalers
    )
    
    NON_NAMESPACED_RESOURCES=(
        namespaces nodes clusterroles clusterrolebindings persistentvolumes
        storageclasses customresourcedefinitions apiservices
        mutatingwebhookconfigurations validatingwebhookconfigurations
        certificatesigningrequests runtimeclasses priorityclasses
    )
    
    RESOURCES_YAML="$REPORT_DIR/cluster-resources.yaml"
    > "$RESOURCES_YAML"  # Clear file
    
    FIRST_DOC=true
    
    # Extract namespaced resources
    for resource_type in "${NAMESPACED_RESOURCES[@]}"; do
        echo "Extracting $resource_type..."
        KUBE_OUTPUT=$(kubectl get "$resource_type" --all-namespaces -o json --context "kind-$CLUSTER_NAME" 2>/dev/null || echo '{"items":[]}')
        
        # Convert each item to YAML and append
        echo "$KUBE_OUTPUT" | jq -r '.items[]' | while IFS= read -r item; do
            if [ -n "$item" ] && [ "$item" != "null" ]; then
                if [ "$FIRST_DOC" = true ]; then
                    FIRST_DOC=false
                else
                    echo "---" >> "$RESOURCES_YAML"
                fi
                echo "$item" | yq eval -P '.' - >> "$RESOURCES_YAML"
            fi
        done
    done
    
    # Extract non-namespaced resources
    for resource_type in "${NON_NAMESPACED_RESOURCES[@]}"; do
        echo "Extracting $resource_type..."
        KUBE_OUTPUT=$(kubectl get "$resource_type" -o json --context "kind-$CLUSTER_NAME" 2>/dev/null || echo '{"items":[]}')
        
        # Convert each item to YAML and append
        echo "$KUBE_OUTPUT" | jq -r '.items[]' | while IFS= read -r item; do
            if [ -n "$item" ] && [ "$item" != "null" ]; then
                if [ "$FIRST_DOC" = true ]; then
                    FIRST_DOC=false
                else
                    echo "---" >> "$RESOURCES_YAML"
                fi
                echo "$item" | yq eval -P '.' - >> "$RESOURCES_YAML"
            fi
        done
    done
    
    echo -e "${GREEN}✅ Cluster resources extracted to $RESOURCES_YAML${NC}"
}

# Run Kyverno validation
run_kyverno_validation() {
    echo -e "${YELLOW}⚙️ [80%] Running Kyverno policy validation...${NC}"
    
    START_TIME=$(date +%s.%N)
    
    # Count total policies
    TOTAL_POLICIES=$(find "$POLICIES_DIR" -name "*.yaml" -type f | wc -l | tr -d ' ')
    echo -e "${BLUE}📊 Found $TOTAL_POLICIES policies to validate${NC}"
    
    # Run policy validation against cluster resources
    CLUSTER_SCAN_REPORT="$REPORT_DIR/cluster-scan-report.yaml"
    CLUSTER_SCAN_STDERR="$REPORT_DIR/cluster-scan-stderr.log"
    
    set +e
    echo -e "${YELLOW}Running cluster resource scan...${NC}"
    KYVERNO_EXPERIMENTAL=true kyverno apply "$POLICIES_DIR" --resource "$REPORT_DIR/cluster-resources.yaml" \\
        --output "$CLUSTER_SCAN_REPORT" --context "kind-$CLUSTER_NAME" \\
        > "$REPORT_DIR/cluster-scan-stdout.log" 2> "$CLUSTER_SCAN_STDERR"
    SCAN_EXIT_CODE=$?
    set -e
    
    # Run manifest tests
    echo -e "${YELLOW}Running manifest tests...${NC}"
    MANIFEST_TEST_REPORT="$REPORT_DIR/manifest-test-report.yaml"
    KYVERNO_EXPERIMENTAL=true kyverno apply "$POLICIES_DIR" --resource "$MANIFESTS_DIR" \\
        --output "$MANIFEST_TEST_REPORT" --context "kind-$CLUSTER_NAME" \\
        > "$REPORT_DIR/manifest-test-stdout.log" 2> "$REPORT_DIR/manifest-test-stderr.log"
    
    END_TIME=$(date +%s.%N)
    DURATION=$(awk "BEGIN {printf \"%.3f\", $END_TIME - $START_TIME}")
    
    # Generate validation summary
    cat > "$REPORT_DIR/validation-summary.md" << EOF
# 🔍 Kind Cluster CIS EKS Compliance Validation Summary

**Generated**: $(date)
**Duration**: ${DURATION}s
**Cluster**: $CLUSTER_NAME

## 📊 Validation Statistics

| Metric | Value |
|--------|-------|
| **Total Policies** | $TOTAL_POLICIES |
| **Validation Duration** | ${DURATION}s |
| **Cluster Scan Exit Code** | $SCAN_EXIT_CODE |
| **Scan Status** | $([ $SCAN_EXIT_CODE -eq 0 ] && echo "✅ Success" || echo "⚠️ Policy Violations Found") |

## 📁 Generated Reports

- **Cluster Resources**: [cluster-resources.yaml](cluster-resources.yaml)
- **Cluster Scan Report**: [cluster-scan-report.yaml](cluster-scan-report.yaml)
- **Manifest Test Report**: [manifest-test-report.yaml](manifest-test-report.yaml)
- **Non-compliant Pod Test**: [noncompliant-pod-test.log](noncompliant-pod-test.log)

## 🎯 Test Results

### Cluster Resource Validation
$([ -f "$CLUSTER_SCAN_REPORT" ] && echo "✅ Completed" || echo "❌ Failed")

### Manifest Testing
$([ -f "$MANIFEST_TEST_REPORT" ] && echo "✅ Completed" || echo "❌ Failed")

### Policy Enforcement
$([ $NONCOMPLIANT_EXIT_CODE -ne 0 ] && echo "✅ Non-compliant resources correctly blocked" || echo "⚠️ Non-compliant resources allowed")

---

*🤖 Generated by Kind Cluster CIS EKS Compliance Validation Suite*
EOF
    
    echo -e "${GREEN}✅ Kyverno validation completed in ${DURATION}s${NC}"
}

# Cleanup cluster
cleanup_cluster() {
    echo -e "${YELLOW}⚙️ [90%] Cleaning up cluster...${NC}"
    
    if [ "${KEEP_CLUSTER:-false}" != "true" ]; then
        kind delete cluster --name "$CLUSTER_NAME" || true
        echo -e "${GREEN}✅ Cluster cleaned up${NC}"
    else
        echo -e "${BLUE}📝 Cluster kept for manual inspection (KEEP_CLUSTER=true)${NC}"
        echo -e "${BLUE}🔧 Access with: kubectl --context kind-$CLUSTER_NAME${NC}"
    fi
}

# Generate final report
generate_final_report() {
    echo -e "${YELLOW}⚙️ [95%] Generating final report...${NC}"
    
    # Count violations and passes
    VIOLATIONS=0
    PASSES=0
    
    if [ -f "$REPORT_DIR/cluster-scan-report.yaml" ]; then
        VIOLATIONS=$(grep -c "result.*fail" "$REPORT_DIR/cluster-scan-report.yaml" 2>/dev/null || echo "0")
        PASSES=$(grep -c "result.*pass" "$REPORT_DIR/cluster-scan-report.yaml" 2>/dev/null || echo "0")
    fi
    
    TOTAL_CHECKS=$((VIOLATIONS + PASSES))
    SUCCESS_RATE="0.0"
    if [ $TOTAL_CHECKS -gt 0 ]; then
        SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", $PASSES * 100 / $TOTAL_CHECKS}")
    fi
    
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                 🎯 ${WHITE}KIND CLUSTER VALIDATION COMPLETE${NC} 🎯                   ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}📊 Final Results:${NC}"
    echo -e "  ${GREEN}✅ Total Checks:${NC} $TOTAL_CHECKS"
    echo -e "  ${GREEN}✅ Passed:${NC} $PASSES"
    echo -e "  ${RED}❌ Failed:${NC} $VIOLATIONS"
    echo -e "  ${CYAN}📈 Success Rate:${NC} ${SUCCESS_RATE}%"
    echo
    echo -e "${WHITE}📁 Reports Generated:${NC}"
    echo -e "  ${CYAN}📄 Summary:${NC} $REPORT_DIR/validation-summary.md"
    echo -e "  ${CYAN}📊 Cluster Scan:${NC} $REPORT_DIR/cluster-scan-report.yaml"
    echo -e "  ${CYAN}🧪 Manifest Tests:${NC} $REPORT_DIR/manifest-test-report.yaml"
    echo
    
    if [ $VIOLATIONS -gt 0 ]; then
        echo -e "${YELLOW}⚠️ Policy violations detected - review reports for details${NC}"
        return 1
    else
        echo -e "${GREEN}🎉 All policies passed successfully!${NC}"
        return 0
    fi
}

# Main execution
main() {
    # Trap cleanup on exit
    trap cleanup_cluster EXIT
    
    check_dependencies
    create_cluster_config
    create_test_manifests
    create_cluster
    install_kyverno
    deploy_test_apps
    extract_cluster_resources
    run_kyverno_validation
    generate_final_report
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi