#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_ROOT/reports/comprehensive"

RUN_UNIT_TESTS="${RUN_UNIT_TESTS:-true}"
RUN_TERRAFORM_TESTS="${RUN_TERRAFORM_TESTS:-true}"
RUN_KIND_CLUSTER_TESTS="${RUN_KIND_CLUSTER_TESTS:-true}"
RUN_CLUSTER_SCAN="${RUN_CLUSTER_SCAN:-false}"
CLUSTER_CONTEXT="${CLUSTER_CONTEXT:-}"

mkdir -p "$REPORT_DIR"

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}            🧪 ${WHITE}COMPREHENSIVE CIS EKS COMPLIANCE TEST SUITE${NC} 🧪             ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${BLUE}📊 Test Configuration:${NC}"
echo -e "  🧪 Unit Tests: $([ "$RUN_UNIT_TESTS" = "true" ] && echo "${GREEN}Enabled${NC}" || echo "${YELLOW}Disabled${NC}")"
echo -e "  🏗️  Terraform Tests: $([ "$RUN_TERRAFORM_TESTS" = "true" ] && echo "${GREEN}Enabled${NC}" || echo "${YELLOW}Disabled${NC}")"
echo -e "  🐳 Kind Cluster Tests: $([ "$RUN_KIND_CLUSTER_TESTS" = "true" ] && echo "${GREEN}Enabled${NC}" || echo "${YELLOW}Disabled${NC}")"
echo -e "  🔍 Cluster Scan: $([ "$RUN_CLUSTER_SCAN" = "true" ] && echo "${GREEN}Enabled${NC}" || echo "${YELLOW}Disabled${NC}")"
echo -e "  📁 Report Directory: $REPORT_DIR"
echo

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TEST_RESULTS=()

START_TIME=$(date +%s.%N)

track_test_result() {
    local test_name="$1"
    local exit_code="$2"
    local duration="$3"
    
    ((TOTAL_TESTS++))
    
    if [ $exit_code -eq 0 ]; then
        ((PASSED_TESTS++))
        TEST_RESULTS+=("✅ $test_name - PASSED (${duration}s)")
        echo -e "${GREEN}✅ $test_name completed successfully${NC}"
    else
        ((FAILED_TESTS++))
        TEST_RESULTS+=("❌ $test_name - FAILED (${duration}s)")
        echo -e "${RED}❌ $test_name failed${NC}"
    fi
}

run_unit_tests() {
    if [ "$RUN_UNIT_TESTS" != "true" ]; then
        echo -e "${YELLOW}⏭️ Skipping unit tests${NC}"
        return 0
    fi
    
    echo -e "${PURPLE}🧪 Running Unit Tests (Policy Validation)${NC}"
    echo "=================================================================="
    
    local test_start=$(date +%s.%N)
    local exit_code=0
    
    set +e
    "$SCRIPT_DIR/test-all-policies.sh"
    exit_code=$?
    set -e
    
    local test_end=$(date +%s.%N)
    local duration=$(awk "BEGIN {printf \"%.2f\", $test_end - $test_start}")
    
    track_test_result "Unit Tests" $exit_code $duration
    
    if [ -d "$PROJECT_ROOT/reports/policy-tests" ]; then
        cp -r "$PROJECT_ROOT/reports/policy-tests" "$REPORT_DIR/"
    fi
    
    echo
}

run_terraform_tests() {
    if [ "$RUN_TERRAFORM_TESTS" != "true" ]; then
        echo -e "${YELLOW}⏭️ Skipping Terraform tests${NC}"
        return 0
    fi
    
    echo -e "${PURPLE}🏗️ Running Terraform Compliance Tests${NC}"
    echo "=================================================================="
    
    local test_start=$(date +%s.%N)
    local exit_code=0
    
    set +e
    "$SCRIPT_DIR/test-terraform-cis-policies.sh"
    exit_code=$?
    set -e
    
    local test_end=$(date +%s.%N)
    local duration=$(awk "BEGIN {printf \"%.2f\", $test_end - $test_start}")
    
    track_test_result "Terraform Tests" $exit_code $duration
    
    if [ -d "$PROJECT_ROOT/reports/terraform-compliance" ]; then
        cp -r "$PROJECT_ROOT/reports/terraform-compliance" "$REPORT_DIR/"
    fi
    
    echo
}

run_kind_cluster_tests() {
    if [ "$RUN_KIND_CLUSTER_TESTS" != "true" ]; then
        echo -e "${YELLOW}⏭️ Skipping Kind cluster tests${NC}"
        return 0
    fi
    
    echo -e "${PURPLE}🐳 Running Kind Cluster Tests${NC}"
    echo "=================================================================="
    
    local test_start=$(date +%s.%N)
    local exit_code=0
    
    set +e
    "$SCRIPT_DIR/kind-cluster-validate.sh"
    exit_code=$?
    set -e
    
    local test_end=$(date +%s.%N)
    local duration=$(awk "BEGIN {printf \"%.2f\", $test_end - $test_start}")
    
    track_test_result "Kind Cluster Tests" $exit_code $duration
    
    if [ -d "$PROJECT_ROOT/reports/kind-cluster" ]; then
        cp -r "$PROJECT_ROOT/reports/kind-cluster" "$REPORT_DIR/"
    fi
    
    echo
}

run_cluster_scan() {
    if [ "$RUN_CLUSTER_SCAN" != "true" ]; then
        echo -e "${YELLOW}⏭️ Skipping cluster scan${NC}"
        return 0
    fi
    
    if [ -z "$CLUSTER_CONTEXT" ]; then
        echo -e "${YELLOW}⏭️ Skipping cluster scan (no cluster context provided)${NC}"
        return 0
    fi
    
    echo -e "${PURPLE}🔍 Running Cluster Resource Scan${NC}"
    echo "=================================================================="
    
    local test_start=$(date +%s.%N)
    local exit_code=0
    
    set +e
    "$SCRIPT_DIR/cluster-resource-scan.sh" "$CLUSTER_CONTEXT"
    exit_code=$?
    set -e
    
    local test_end=$(date +%s.%N)
    local duration=$(awk "BEGIN {printf \"%.2f\", $test_end - $test_start}")
    
    track_test_result "Cluster Scan" $exit_code $duration
    
    if [ -d "$PROJECT_ROOT/reports/cluster-scan" ]; then
        cp -r "$PROJECT_ROOT/reports/cluster-scan" "$REPORT_DIR/"
    fi
    
    echo
}

generate_comprehensive_summary() {
    echo -e "${PURPLE}📊 Generating Comprehensive Test Summary${NC}"
    echo "=================================================================="
    
    local end_time=$(date +%s.%N)
    local total_duration=$(awk "BEGIN {printf \"%.2f\", $end_time - $START_TIME}")
    local success_rate=$(awk "BEGIN {printf \"%.1f\", $PASSED_TESTS * 100 / $TOTAL_TESTS}")
    
    cat > "$REPORT_DIR/comprehensive-summary.md" << EOF
# 🧪 Comprehensive CIS EKS Compliance Test Summary

**Generated**: $(date)
**Total Duration**: ${total_duration}s
**Test Suite Version**: Enhanced v2.0

## 🎯 Executive Overview

| Metric | Value |
|--------|-------|
| **Total Test Suites** | $TOTAL_TESTS |
| **✅ Passed** | $PASSED_TESTS |
| **❌ Failed** | $FAILED_TESTS |
| **Success Rate** | ${success_rate}% |
| **Overall Status** | $([ $FAILED_TESTS -eq 0 ] && echo "🟢 All Tests Passed" || echo "🔴 Some Tests Failed") |

## 📋 Test Results Breakdown

EOF
    
    for result in "${TEST_RESULTS[@]}"; do
        echo "- $result" >> "$REPORT_DIR/comprehensive-summary.md"
    done
    
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF

## 📊 Test Coverage Matrix

| Test Type | Status | Coverage | Purpose |
|-----------|--------|----------|---------|
| Unit Tests | $([ "$RUN_UNIT_TESTS" = "true" ] && echo "✅ Executed" || echo "⏭️ Skipped") | Kubernetes Policies | Individual policy validation |
| Terraform Tests | $([ "$RUN_TERRAFORM_TESTS" = "true" ] && echo "✅ Executed" || echo "⏭️ Skipped") | Infrastructure Policies | Terraform plan validation |
| Kind Cluster Tests | $([ "$RUN_KIND_CLUSTER_TESTS" = "true" ] && echo "✅ Executed" || echo "⏭️ Skipped") | Live Cluster | End-to-end validation |
| Cluster Scan | $([ "$RUN_CLUSTER_SCAN" = "true" ] && echo "✅ Executed" || echo "⏭️ Skipped") | Production Cluster | Real environment scan |

## 📁 Generated Reports

### 🧪 Unit Test Reports
EOF

if [ -d "$REPORT_DIR/policy-tests" ]; then
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF
- **Summary**: [policy-tests/summary.md](policy-tests/summary.md)
- **Detailed Results**: [policy-tests/detailed-results.md](policy-tests/detailed-results.md)
- **Execution Stats**: [policy-tests/execution-stats.json](policy-tests/execution-stats.json)
EOF
else
    echo "- No unit test reports available" >> "$REPORT_DIR/comprehensive-summary.md"
fi

cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF

### 🏗️ Terraform Test Reports
EOF

if [ -d "$REPORT_DIR/terraform-compliance" ]; then
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF
- **Compliant Scan**: [terraform-compliance/compliant-plan-scan.md](terraform-compliance/compliant-plan-scan.md)
- **Non-compliant Scan**: [terraform-compliance/noncompliant-plan-scan.md](terraform-compliance/noncompliant-plan-scan.md)
EOF
else
    echo "- No Terraform test reports available" >> "$REPORT_DIR/comprehensive-summary.md"
fi

cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF

### 🐳 Kind Cluster Test Reports
EOF

if [ -d "$REPORT_DIR/kind-cluster" ]; then
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF
- **Validation Summary**: [kind-cluster/validation-summary.md](kind-cluster/validation-summary.md)
- **Cluster Scan**: [kind-cluster/cluster-scan-report.yaml](kind-cluster/cluster-scan-report.yaml)
- **Manifest Tests**: [kind-cluster/manifest-test-report.yaml](kind-cluster/manifest-test-report.yaml)
EOF
else
    echo "- No Kind cluster test reports available" >> "$REPORT_DIR/comprehensive-summary.md"
fi

cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF

### 🔍 Cluster Scan Reports
EOF

if [ -d "$REPORT_DIR/cluster-scan" ]; then
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF
- **Compliance Summary**: [cluster-scan/compliance-summary.md](cluster-scan/compliance-summary.md)
- **Policy Scan Report**: [cluster-scan/policy-scan-report.yaml](cluster-scan/policy-scan-report.yaml)
- **Cluster Resources**: [cluster-scan/cluster-resources.yaml](cluster-scan/cluster-resources.yaml)
EOF
else
    echo "- No cluster scan reports available" >> "$REPORT_DIR/comprehensive-summary.md"
fi

cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF

## 🔧 Recommendations

EOF

if [ $FAILED_TESTS -eq 0 ]; then
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF
✅ **All tests passed successfully!**

- Continue regular compliance monitoring
- Consider implementing automated compliance checks in CI/CD
- Schedule periodic cluster scans for production environments
- Review and update policies as new CIS benchmarks are released
EOF
else
    cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF
⚠️ **Some tests failed - action required:**

1. **Review failed test reports** for specific issues
2. **Fix policy violations** identified in the scans
3. **Update infrastructure** to meet CIS EKS benchmarks
4. **Re-run tests** after implementing fixes
5. **Consider staging environment** for validation before production
EOF
fi

cat >> "$REPORT_DIR/comprehensive-summary.md" << EOF

## 📈 Continuous Improvement

- **Regular Testing**: Run comprehensive tests on each code change
- **Policy Updates**: Keep policies aligned with latest CIS EKS benchmarks
- **Environment Validation**: Test against multiple cluster configurations
- **Monitoring Integration**: Implement continuous compliance monitoring

---

*🤖 Generated by Comprehensive CIS EKS Compliance Test Suite v2.0*
EOF
    
    echo -e "${GREEN}✅ Comprehensive summary generated${NC}"
}

generate_final_report() {
    local success_rate=$(awk "BEGIN {printf \"%.1f\", $PASSED_TESTS * 100 / $TOTAL_TESTS}")
    local total_duration=$(awk "BEGIN {printf \"%.2f\", $(date +%s.%N) - $START_TIME}")
    
    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                🎯 ${WHITE}COMPREHENSIVE TEST SUITE COMPLETE${NC} 🎯                  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${WHITE}📊 Final Results:${NC}"
    echo -e "  ${BLUE}🧪 Total Test Suites:${NC} $TOTAL_TESTS"
    echo -e "  ${GREEN}✅ Passed:${NC} $PASSED_TESTS"
    echo -e "  ${RED}❌ Failed:${NC} $FAILED_TESTS"
    echo -e "  ${CYAN}📈 Success Rate:${NC} ${success_rate}%"
    echo -e "  ${BLUE}⏱️ Total Duration:${NC} ${total_duration}s"
    echo
    echo -e "${WHITE}📁 Comprehensive Report:${NC}"
    echo -e "  ${CYAN}📄 Summary:${NC} $REPORT_DIR/comprehensive-summary.md"
    echo -e "  ${CYAN}📊 All Reports:${NC} $REPORT_DIR/"
    echo
    
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}🚨 Some tests failed - review reports for remediation guidance${NC}"
        return 1
    else
        echo -e "${GREEN}🎉 All tests passed! Your CIS EKS compliance is excellent!${NC}"
        return 0
    fi
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Run comprehensive CIS EKS compliance tests including unit tests, Terraform validation,
Kind cluster testing, and optional cluster scanning.

Environment Variables:
  RUN_UNIT_TESTS=true|false         Enable/disable unit tests (default: true)
  RUN_TERRAFORM_TESTS=true|false    Enable/disable Terraform tests (default: true)
  RUN_KIND_CLUSTER_TESTS=true|false Enable/disable Kind cluster tests (default: true)
  RUN_CLUSTER_SCAN=true|false       Enable/disable cluster scan (default: false)
  CLUSTER_CONTEXT=context           Cluster context for scanning (required if RUN_CLUSTER_SCAN=true)

Examples:
  # Run all tests except cluster scan
  $0
  
  # Run only unit and Terraform tests
  RUN_KIND_CLUSTER_TESTS=false $0
  
  # Run all tests including cluster scan
  RUN_CLUSTER_SCAN=true CLUSTER_CONTEXT=production $0
  
  # Run only Kind cluster tests
  RUN_UNIT_TESTS=false RUN_TERRAFORM_TESTS=false $0

Options:
  -h, --help                        Show this help message

EOF
}

main() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    run_unit_tests
    run_terraform_tests
    run_kind_cluster_tests
    run_cluster_scan
    
    generate_comprehensive_summary
    generate_final_report
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi