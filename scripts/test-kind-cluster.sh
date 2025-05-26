#!/bin/bash
# Unified script for Kind cluster testing
# End-to-end validation of Kyverno policies in a real Kubernetes environment

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLUSTER_NAME="${CLUSTER_NAME:-cis-eks-kyverno-test}"
REPORT_DIR="$PROJECT_ROOT/reports/kind-cluster"
MANIFESTS_DIR="$PROJECT_ROOT/tests/kind-manifests"
POLICIES_DIR="$PROJECT_ROOT/policies/kubernetes"
NAMESPACE="test-policies"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME      Cluster name (default: $CLUSTER_NAME)"
    echo "  -k, --keep           Keep cluster running after tests"
    echo "  -s, --skip-create    Skip cluster creation (use existing)"
    echo "  -c, --cleanup-only   Only cleanup existing cluster"
    echo "  -h, --help           Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Full test cycle"
    echo "  $0 --keep                   # Keep cluster after tests"
    echo "  $0 --skip-create            # Use existing cluster"
    echo "  $0 --cleanup-only           # Only cleanup"
    exit 0
}

# Parse command line arguments
KEEP_CLUSTER=false
SKIP_CREATE=false
CLEANUP_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        -k|--keep)
            KEEP_CLUSTER=true
            shift
            ;;
        -s|--skip-create)
            SKIP_CREATE=true
            shift
            ;;
        -c|--cleanup-only)
            CLEANUP_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Initialize
mkdir -p "$REPORT_DIR" "$MANIFESTS_DIR"

# Function to check dependencies
check_dependencies() {
    echo -e "${BLUE}🔍 Checking dependencies...${NC}"
    
    local missing_deps=()
    
    for cmd in docker kubectl kyverno; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check/install kind
    if ! command -v kind &> /dev/null; then
        echo -e "${YELLOW}📦 Installing kind...${NC}"
        GO111MODULE="on" go install sigs.k8s.io/kind@latest 2>/dev/null || {
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
        }
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing dependencies: ${missing_deps[*]}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All dependencies satisfied${NC}"
}

# Function to cleanup cluster
cleanup_cluster() {
    echo -e "${YELLOW}🧹 Cleaning up cluster...${NC}"
    if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
        kind delete cluster --name "$CLUSTER_NAME"
        echo -e "${GREEN}✅ Cluster deleted${NC}"
    else
        echo -e "${BLUE}ℹ️  No cluster to cleanup${NC}"
    fi
}

# Function to create cluster
create_cluster() {
    echo -e "${BLUE}🚀 Creating Kind cluster...${NC}"
    
    # Create cluster config
    cat > "$REPORT_DIR/kind-cluster-config.yaml" << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $CLUSTER_NAME
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "node-role.kubernetes.io/control-plane=true"
  - role: worker
    kubeadmConfigPatches:
      - |
        kind: JoinConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "node-role.kubernetes.io/worker=true"
EOF
    
    # Create cluster
    kind create cluster --config "$REPORT_DIR/kind-cluster-config.yaml" --wait 2m
    
    echo -e "${GREEN}✅ Cluster created${NC}"
    
    # Wait for nodes
    echo -e "${YELLOW}⏳ Waiting for nodes to be ready...${NC}"
    kubectl wait --for=condition=Ready nodes --all --timeout=120s
    
    echo -e "${GREEN}✅ All nodes ready${NC}"
}

# Function to install Kyverno
install_kyverno() {
    echo -e "${BLUE}📦 Installing Kyverno...${NC}"
    
    # Install Kyverno
    kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml
    
    # Wait for Kyverno
    echo -e "${YELLOW}⏳ Waiting for Kyverno to be ready...${NC}"
    kubectl -n kyverno wait --for=condition=ready pod -l app.kubernetes.io/component=kyverno --timeout=120s
    
    echo -e "${GREEN}✅ Kyverno installed${NC}"
}

# Function to apply policies
apply_policies() {
    echo -e "${BLUE}📋 Applying Kyverno policies...${NC}"
    
    local policy_count=0
    local failed_count=0
    
    # Apply all policies
    for policy_dir in "$POLICIES_DIR"/*; do
        if [ -d "$policy_dir" ]; then
            for policy in "$policy_dir"/*.yaml; do
                if [ -f "$policy" ]; then
                    ((policy_count++))
                    echo -ne "\r${CYAN}Applying policies: $policy_count${NC}"
                    
                    if ! kubectl apply -f "$policy" > /dev/null 2>&1; then
                        ((failed_count++))
                        echo -e "\n${RED}❌ Failed to apply: $(basename "$policy")${NC}"
                    fi
                fi
            done
        fi
    done
    
    echo # New line
    echo -e "${GREEN}✅ Applied $((policy_count - failed_count))/$policy_count policies${NC}"
    
    # Wait for policies to be ready
    echo -e "${YELLOW}⏳ Waiting for policies to be ready...${NC}"
    sleep 5
}

# Function to run tests
run_tests() {
    echo -e "${BLUE}🧪 Running compliance tests...${NC}"
    
    # Create test namespace
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Test results
    local test_results="$REPORT_DIR/test-results.md"
    
    cat > "$test_results" << EOF
# Kind Cluster Test Results

**Cluster**: $CLUSTER_NAME
**Date**: $(date)
**Namespace**: $NAMESPACE

## Test Summary

EOF
    
    # Test 1: Compliant Pod
    echo -e "\n${YELLOW}Test 1: Deploying compliant pod...${NC}"
    
    cat > "$MANIFESTS_DIR/compliant-pod.yaml" << EOF
apiVersion: v1
kind: Pod
metadata:
  name: compliant-pod
  namespace: $NAMESPACE
  annotations:
    image-scanning: "enabled"
spec:
  serviceAccountName: restricted-sa
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: nginx
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
EOF
    
    if kubectl apply -f "$MANIFESTS_DIR/compliant-pod.yaml" 2>&1; then
        echo -e "${GREEN}✅ Compliant pod created successfully${NC}"
        echo "- ✅ Compliant pod: **PASS**" >> "$test_results"
    else
        echo -e "${RED}❌ Compliant pod creation failed${NC}"
        echo "- ❌ Compliant pod: **FAIL**" >> "$test_results"
    fi
    
    # Test 2: Non-compliant Pod
    echo -e "\n${YELLOW}Test 2: Deploying non-compliant pod...${NC}"
    
    cat > "$MANIFESTS_DIR/noncompliant-pod.yaml" << EOF
apiVersion: v1
kind: Pod
metadata:
  name: noncompliant-pod
  namespace: $NAMESPACE
spec:
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      runAsUser: 0
      privileged: true
EOF
    
    # This should fail in enforce mode
    if ! kubectl apply -f "$MANIFESTS_DIR/noncompliant-pod.yaml" 2>&1 | grep -q "denied"; then
        echo -e "${YELLOW}⚠️  Non-compliant pod was created (policies in audit mode)${NC}"
        echo "- ⚠️  Non-compliant pod: **Created** (audit mode)" >> "$test_results"
    else
        echo -e "${GREEN}✅ Non-compliant pod was blocked${NC}"
        echo "- ✅ Non-compliant pod: **Blocked**" >> "$test_results"
    fi
    
    # Generate cluster scan report
    echo -e "\n${BLUE}📊 Generating cluster scan report...${NC}"
    
    # Export cluster resources
    kubectl get all,nodes,namespaces,clusterroles,clusterrolebindings -A -o yaml > "$REPORT_DIR/cluster-resources.yaml" 2>/dev/null
    
    # Run offline scan
    echo "## Offline Policy Scan Results" >> "$test_results"
    echo '```' >> "$test_results"
    KYVERNO_EXPERIMENTAL=true kyverno apply "$POLICIES_DIR" --resource "$REPORT_DIR/cluster-resources.yaml" 2>&1 | head -100 >> "$test_results"
    echo '```' >> "$test_results"
    
    echo -e "${GREEN}✅ Tests completed${NC}"
    echo -e "${BLUE}📊 Results saved to: $test_results${NC}"
}

# Main execution
echo -e "${PURPLE}🚀 Kind Cluster CIS EKS Compliance Testing${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Cluster Name: $CLUSTER_NAME"
echo -e "Report Directory: $REPORT_DIR"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Check dependencies
check_dependencies

# Handle cleanup-only mode
if [[ "$CLEANUP_ONLY" == "true" ]]; then
    cleanup_cluster
    exit 0
fi

# Create cluster if needed
if [[ "$SKIP_CREATE" != "true" ]]; then
    # Cleanup existing cluster
    if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
        echo -e "${YELLOW}⚠️  Cluster already exists, recreating...${NC}"
        cleanup_cluster
    fi
    
    create_cluster
    install_kyverno
else
    # Verify cluster exists
    if ! kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
        echo -e "${RED}❌ Cluster not found: $CLUSTER_NAME${NC}"
        exit 1
    fi
    
    # Set context
    kubectl config use-context "kind-$CLUSTER_NAME"
fi

# Run tests
apply_policies
run_tests

# Cleanup if requested
if [[ "$KEEP_CLUSTER" != "true" ]]; then
    echo -e "\n${YELLOW}🧹 Cleaning up...${NC}"
    cleanup_cluster
else
    echo -e "\n${BLUE}ℹ️  Cluster kept running: $CLUSTER_NAME${NC}"
    echo -e "${BLUE}   To interact: kubectl config use-context kind-$CLUSTER_NAME${NC}"
    echo -e "${BLUE}   To cleanup: $0 --cleanup-only --name $CLUSTER_NAME${NC}"
fi

echo -e "\n${GREEN}✅ All done!${NC}"