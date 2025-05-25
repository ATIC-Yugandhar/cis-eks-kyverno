#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_ROOT/reports/cluster-scan"
POLICIES_DIR="$PROJECT_ROOT/policies/kubernetes"

CLUSTER_CONTEXT="${1:-$(kubectl config current-context)}"
NAMESPACE="${2:-all}"

mkdir -p "$REPORT_DIR"

echo -e "${PURPLE}🔍 Starting Cluster Resource CIS Compliance Scan${NC}"
echo -e "${BLUE}📊 Configuration:${NC}"
echo -e "  🔧 Cluster Context: $CLUSTER_CONTEXT"
echo -e "  📦 Namespace: $NAMESPACE"
echo -e "  📁 Report Directory: $REPORT_DIR"
echo -e "  📋 Policies Directory: $POLICIES_DIR"
echo

check_dependencies() {
    echo -e "${YELLOW}⚙️ [10%] Checking dependencies...${NC}"
    
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl not found${NC}"
        exit 1
    fi
    
    if ! command -v kyverno &> /dev/null; then
        echo -e "${RED}❌ kyverno CLI not found${NC}"
        exit 1
    fi
    
    if ! command -v yq &> /dev/null; then
        echo -e "${YELLOW}Installing yq...${NC}"
        YQ_VERSION="v4.40.5"
        YQ_BINARY="yq_linux_amd64"
        if [[ "$(uname -s)" == "Darwin" ]]; then
            YQ_BINARY="yq_darwin_amd64"
        fi
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"
        curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -o "$INSTALL_DIR/yq"
        chmod +x "$INSTALL_DIR/yq"
        export PATH="$INSTALL_DIR:$PATH"
    fi
    
    if ! kubectl cluster-info --context "$CLUSTER_CONTEXT" &> /dev/null; then
        echo -e "${RED}❌ Cannot connect to cluster context: $CLUSTER_CONTEXT${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All dependencies satisfied${NC}"
}

extract_cluster_resources() {
    echo -e "${YELLOW}⚙️ [30%] Extracting cluster resources...${NC}"
    
    NAMESPACED_RESOURCES=(
        pods services deployments statefulsets daemonsets
        configmaps secrets serviceaccounts
        roles rolebindings networkpolicies
        limitranges resourcequotas
    )
    
    NON_NAMESPACED_RESOURCES=(
        namespaces nodes
        clusterroles clusterrolebindings
        persistentvolumes storageclasses
        customresourcedefinitions apiservices
        mutatingwebhookconfigurations validatingwebhookconfigurations
        certificatesigningrequests
        runtimeclasses priorityclasses
    )
    
    RESOURCES_YAML="$REPORT_DIR/cluster-resources.yaml"
    RESOURCES_JSON="$REPORT_DIR/cluster-resources.json"
    
    > "$RESOURCES_YAML"
    echo "[]" > "$RESOURCES_JSON"
    
    EXTRACTED_COUNT=0
    TOTAL_RESOURCE_TYPES=$((${#NAMESPACED_RESOURCES[@]} + ${#NON_NAMESPACED_RESOURCES[@]}))
    CURRENT_TYPE=0
    
    for resource_type in "${NAMESPACED_RESOURCES[@]}"; do
        ((CURRENT_TYPE++))
        PROGRESS=$(awk "BEGIN {printf \"%.1f\", $CURRENT_TYPE * 100 / $TOTAL_RESOURCE_TYPES}")
        echo -e "${BLUE}  [$PROGRESS%] Extracting $resource_type...${NC}"
        
        if [ "$NAMESPACE" = "all" ]; then
            KUBE_OUTPUT=$(kubectl get "$resource_type" --all-namespaces -o json --context "$CLUSTER_CONTEXT" 2>/dev/null || echo '{"items":[]}')
        else
            KUBE_OUTPUT=$(kubectl get "$resource_type" -n "$NAMESPACE" -o json --context "$CLUSTER_CONTEXT" 2>/dev/null || echo '{"items":[]}')
        fi
        
        ITEM_COUNT=$(echo "$KUBE_OUTPUT" | jq '.items | length')
        if [ "$ITEM_COUNT" -gt 0 ]; then
            echo "$KUBE_OUTPUT" | jq '.items[]' >> "$RESOURCES_JSON.tmp"
            EXTRACTED_COUNT=$((EXTRACTED_COUNT + ITEM_COUNT))
        fi
    done
    
    for resource_type in "${NON_NAMESPACED_RESOURCES[@]}"; do
        ((CURRENT_TYPE++))
        PROGRESS=$(awk "BEGIN {printf \"%.1f\", $CURRENT_TYPE * 100 / $TOTAL_RESOURCE_TYPES}")
        echo -e "${BLUE}  [$PROGRESS%] Extracting $resource_type...${NC}"
        
        KUBE_OUTPUT=$(kubectl get "$resource_type" -o json --context "$CLUSTER_CONTEXT" 2>/dev/null || echo '{"items":[]}')
        
        ITEM_COUNT=$(echo "$KUBE_OUTPUT" | jq '.items | length')
        if [ "$ITEM_COUNT" -gt 0 ]; then
            echo "$KUBE_OUTPUT" | jq '.items[]' >> "$RESOURCES_JSON.tmp"
            EXTRACTED_COUNT=$((EXTRACTED_COUNT + ITEM_COUNT))
        fi
    done
    
    if [ -f "$RESOURCES_JSON.tmp" ]; then
        jq -s '.' "$RESOURCES_JSON.tmp" > "$RESOURCES_JSON"
        rm "$RESOURCES_JSON.tmp"
        
        jq -r '.[]' "$RESOURCES_JSON" | while IFS= read -r item; do
            if [ -n "$item" ] && [ "$item" != "null" ]; then
                echo "---"
                echo "$item" | yq eval -P '.' -
            fi
        done > "$RESOURCES_YAML"
    else
        echo "[]" > "$RESOURCES_JSON"
        echo "# No resources found" > "$RESOURCES_YAML"
    fi
    
    echo -e "${GREEN}✅ Extracted $EXTRACTED_COUNT resources from cluster${NC}"
}

run_policy_validation() {
    echo -e "${YELLOW}⚙️ [60%] Running CIS policy validation...${NC}"
    
    START_TIME=$(date +%s.%N)
    
    TOTAL_POLICIES=$(find "$POLICIES_DIR" -name "*.yaml" -type f | wc -l | tr -d ' ')
    echo -e "${BLUE}📊 Validating $TOTAL_POLICIES policies against cluster resources${NC}"
    
    SCAN_REPORT="$REPORT_DIR/policy-scan-report.yaml"
    SCAN_STDOUT="$REPORT_DIR/policy-scan-stdout.log"
    SCAN_STDERR="$REPORT_DIR/policy-scan-stderr.log"
    
    set +e
    KYVERNO_EXPERIMENTAL=true kyverno apply "$POLICIES_DIR" \\
        --resource "$REPORT_DIR/cluster-resources.yaml" \\
        --output "$SCAN_REPORT" \\
        > "$SCAN_STDOUT" 2> "$SCAN_STDERR"
    SCAN_EXIT_CODE=$?
    set -e
    
    END_TIME=$(date +%s.%N)
    DURATION=$(awk "BEGIN {printf \"%.3f\", $END_TIME - $START_TIME}")
    
    VIOLATIONS=0
    PASSES=0
    WARNINGS=0
    
    if [ -f "$SCAN_REPORT" ]; then
        VIOLATIONS=$(grep -c "result.*fail" "$SCAN_REPORT" 2>/dev/null || echo "0")
        PASSES=$(grep -c "result.*pass" "$SCAN_REPORT" 2>/dev/null || echo "0")
        WARNINGS=$(grep -c "result.*warn" "$SCAN_REPORT" 2>/dev/null || echo "0")
    fi
    
    TOTAL_CHECKS=$((VIOLATIONS + PASSES + WARNINGS))
    SUCCESS_RATE="0.0"
    if [ $TOTAL_CHECKS -gt 0 ]; then
        SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", $PASSES * 100 / $TOTAL_CHECKS}")
    fi
    
    echo -e "${GREEN}✅ Policy validation completed in ${DURATION}s${NC}"
    echo -e "${BLUE}📊 Results: $PASSES passed, $VIOLATIONS failed, $WARNINGS warnings${NC}"
    
    echo "$VIOLATIONS" > "$REPORT_DIR/.violations_count"
    echo "$PASSES" > "$REPORT_DIR/.passes_count"
    echo "$WARNINGS" > "$REPORT_DIR/.warnings_count"
    echo "$SUCCESS_RATE" > "$REPORT_DIR/.success_rate"
    echo "$DURATION" > "$REPORT_DIR/.duration"
}

generate_compliance_summary() {
    echo -e "${YELLOW}⚙️ [80%] Generating compliance summary...${NC}"
    
    VIOLATIONS=$(cat "$REPORT_DIR/.violations_count" 2>/dev/null || echo "0")
    PASSES=$(cat "$REPORT_DIR/.passes_count" 2>/dev/null || echo "0")
    WARNINGS=$(cat "$REPORT_DIR/.warnings_count" 2>/dev/null || echo "0")
    SUCCESS_RATE=$(cat "$REPORT_DIR/.success_rate" 2>/dev/null || echo "0.0")
    DURATION=$(cat "$REPORT_DIR/.duration" 2>/dev/null || echo "0.0")
    TOTAL_CHECKS=$((VIOLATIONS + PASSES + WARNINGS))
    
    SECTION_2_VIOLATIONS=0
    SECTION_3_VIOLATIONS=0
    SECTION_4_VIOLATIONS=0
    SECTION_5_VIOLATIONS=0
    
    if [ -f "$REPORT_DIR/policy-scan-report.yaml" ]; then
        SECTION_2_VIOLATIONS=$(grep -c "custom-2.*fail" "$REPORT_DIR/policy-scan-report.yaml" 2>/dev/null || echo "0")
        SECTION_3_VIOLATIONS=$(grep -c "custom-3.*fail" "$REPORT_DIR/policy-scan-report.yaml" 2>/dev/null || echo "0")
        SECTION_4_VIOLATIONS=$(grep -c "custom-4.*fail" "$REPORT_DIR/policy-scan-report.yaml" 2>/dev/null || echo "0")
        SECTION_5_VIOLATIONS=$(grep -c "custom-5.*fail" "$REPORT_DIR/policy-scan-report.yaml" 2>/dev/null || echo "0")
    fi
    
    cat > "$REPORT_DIR/compliance-summary.md" << EOF
# 🔍 Cluster CIS EKS Compliance Scan Summary

**Generated**: $(date)
**Cluster Context**: $CLUSTER_CONTEXT
**Namespace Scope**: $NAMESPACE
**Scan Duration**: ${DURATION}s

## 🎯 Executive Summary

| Metric | Value |
|--------|-------|
| **Total Checks** | $TOTAL_CHECKS |
| **✅ Passed** | $PASSES |
| **❌ Failed** | $VIOLATIONS |
| **⚠️ Warnings** | $WARNINGS |
| **Success Rate** | ${SUCCESS_RATE}% |
| **Compliance Status** | $([ $VIOLATIONS -eq 0 ] && echo "🟢 Compliant" || echo "🔴 Non-Compliant") |

## 📊 CIS Section Breakdown

| CIS Section | Failed Checks | Description |
|-------------|---------------|-------------|
| **Section 2** | $SECTION_2_VIOLATIONS | Control Plane Configuration |
| **Section 3** | $SECTION_3_VIOLATIONS | Worker Node Configuration |
| **Section 4** | $SECTION_4_VIOLATIONS | RBAC and Service Accounts |
| **Section 5** | $SECTION_5_VIOLATIONS | Pod Security Standards |

## 📁 Generated Reports

- **Cluster Resources**: [cluster-resources.yaml](cluster-resources.yaml) | [cluster-resources.json](cluster-resources.json)
- **Policy Scan Report**: [policy-scan-report.yaml](policy-scan-report.yaml)
- **Scan Output**: [policy-scan-stdout.log](policy-scan-stdout.log) | [policy-scan-stderr.log](policy-scan-stderr.log)

## 🔧 Recommendations

$(if [ $VIOLATIONS -gt 0 ]; then
    echo "1. Review the policy scan report for specific violations"
    echo "2. Focus on CIS sections with the highest number of failures"
    echo "3. Implement recommended security controls"
    echo "4. Re-run scan after remediation"
else
    echo "✅ Cluster is compliant with all CIS EKS benchmarks"
    echo "🔄 Continue regular compliance monitoring"
fi)

---

*🤖 Generated by Cluster Resource CIS Compliance Scanner*
EOF
    
    echo -e "${GREEN}✅ Compliance summary generated${NC}"
}

generate_final_report() {
    echo -e "${YELLOW}⚙️ [90%] Generating final report...${NC}"
    
    VIOLATIONS=$(cat "$REPORT_DIR/.violations_count" 2>/dev/null || echo "0")
    PASSES=$(cat "$REPORT_DIR/.passes_count" 2>/dev/null || echo "0")
    SUCCESS_RATE=$(cat "$REPORT_DIR/.success_rate" 2>/dev/null || echo "0.0")
    
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}               🔍 ${WHITE}CLUSTER COMPLIANCE SCAN COMPLETE${NC} 🔍                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}📊 Final Results:${NC}"
    echo -e "  ${GREEN}✅ Passed:${NC} $PASSES"
    echo -e "  ${RED}❌ Failed:${NC} $VIOLATIONS"
    echo -e "  ${CYAN}📈 Success Rate:${NC} ${SUCCESS_RATE}%"
    echo -e "  ${BLUE}📋 Status:${NC} $([ $VIOLATIONS -eq 0 ] && echo "${GREEN}Compliant${NC}" || echo "${RED}Non-Compliant${NC}")"
    echo
    echo -e "${WHITE}📁 Reports Location:${NC}"
    echo -e "  ${CYAN}📄 Summary:${NC} $REPORT_DIR/compliance-summary.md"
    echo -e "  ${CYAN}📊 Detailed:${NC} $REPORT_DIR/policy-scan-report.yaml"
    echo
    
    rm -f "$REPORT_DIR/.violations_count" "$REPORT_DIR/.passes_count" "$REPORT_DIR/.warnings_count" \\
          "$REPORT_DIR/.success_rate" "$REPORT_DIR/.duration"
    
    if [ $VIOLATIONS -gt 0 ]; then
        echo -e "${YELLOW}⚠️ Compliance violations detected - review reports for remediation${NC}"
        return 1
    else
        echo -e "${GREEN}🎉 Cluster is fully compliant with CIS EKS benchmarks!${NC}"
        return 0
    fi
}

show_help() {
    cat << EOF
Usage: $0 [CLUSTER_CONTEXT] [NAMESPACE]

Scan a Kubernetes cluster for CIS EKS compliance using Kyverno policies.

Arguments:
  CLUSTER_CONTEXT  Kubernetes cluster context (default: current context)
  NAMESPACE        Namespace to scan (default: all)

Environment Variables:
  REPORT_DIR       Override report directory (default: reports/cluster-scan)
  POLICIES_DIR     Override policies directory (default: policies/kubernetes)

Examples:
  $0                           # Scan current context, all namespaces
  $0 production               # Scan production context, all namespaces  
  $0 staging kube-system      # Scan staging context, kube-system namespace

EOF
}

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    check_dependencies
    extract_cluster_resources
    run_policy_validation
    generate_compliance_summary
    generate_final_report
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi