#!/bin/bash
# Master script to run all test types
# Orchestrates Kubernetes, Terraform, and Kind cluster tests

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_ROOT/reports/comprehensive"
SUMMARY_FILE="$REPORT_DIR/comprehensive-summary.md"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -k, --kubernetes-only   Run only Kubernetes policy tests"
    echo "  -t, --terraform-only    Run only Terraform policy tests"
    echo "  -c, --cluster-only      Run only Kind cluster tests"
    echo "  -s, --skip-cluster      Skip Kind cluster tests"
    echo "  -q, --quiet             Minimal output"
    echo "  -h, --help              Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all tests"
    echo "  $0 --skip-cluster       # Run all except cluster tests"
    echo "  $0 --kubernetes-only    # Run only Kubernetes tests"
    exit 0
}

# Parse command line arguments
RUN_KUBERNETES=true
RUN_TERRAFORM=true
RUN_CLUSTER=true
QUIET_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--kubernetes-only)
            RUN_TERRAFORM=false
            RUN_CLUSTER=false
            shift
            ;;
        -t|--terraform-only)
            RUN_KUBERNETES=false
            RUN_CLUSTER=false
            shift
            ;;
        -c|--cluster-only)
            RUN_KUBERNETES=false
            RUN_TERRAFORM=false
            shift
            ;;
        -s|--skip-cluster)
            RUN_CLUSTER=false
            shift
            ;;
        -q|--quiet)
            QUIET_MODE=true
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
mkdir -p "$REPORT_DIR"
OVERALL_START=$(date +%s)
TEST_RESULTS=()

# Function to display banner
show_banner() {
    if [[ "$QUIET_MODE" != "true" ]]; then
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}   🚀 CIS EKS Kyverno Test Suite${NC}"
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}📅 Date: $(date)${NC}"
        echo -e "${BLUE}📁 Reports: $REPORT_DIR${NC}"
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    fi
}

# Function to run a test suite
run_test_suite() {
    local suite_name=$1
    local script_name=$2
    local extra_args="${3:-}"
    
    echo -e "\n${BLUE}🧪 Running $suite_name Tests${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    local start_time=$(date +%s)
    local status="PASS"
    local output_file="$REPORT_DIR/${suite_name,,}-output.log"
    
    # Run the test
    if [[ "$QUIET_MODE" == "true" ]]; then
        if "$SCRIPT_DIR/$script_name" $extra_args > "$output_file" 2>&1; then
            echo -e "${GREEN}✅ $suite_name tests passed${NC}"
        else
            status="FAIL"
            echo -e "${RED}❌ $suite_name tests failed${NC}"
            echo -e "${YELLOW}   See: $output_file${NC}"
        fi
    else
        if "$SCRIPT_DIR/$script_name" $extra_args; then
            echo -e "${GREEN}✅ $suite_name tests completed successfully${NC}"
        else
            status="FAIL"
            echo -e "${RED}❌ $suite_name tests failed${NC}"
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    TEST_RESULTS+=("$suite_name|$status|${duration}s")
    
    return 0
}

# Initialize summary report
init_summary() {
    cat > "$SUMMARY_FILE" << EOF
# 📊 Comprehensive Test Summary

**Generated**: $(date)
**Test Suite Version**: 1.0.0

## 🎯 Executive Summary

This report summarizes the results of all CIS EKS compliance tests using Kyverno policies.

## 📋 Test Results

| Test Suite | Status | Duration | Details |
|------------|--------|----------|---------|
EOF
}

# Main execution
show_banner
init_summary

# Check dependencies
echo -e "${BLUE}🔍 Checking dependencies...${NC}"
missing_deps=()

for cmd in kyverno kubectl terraform; do
    if ! command -v "$cmd" &> /dev/null; then
        missing_deps+=("$cmd")
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing dependencies: ${missing_deps[*]}${NC}"
    echo -e "${YELLOW}Please install missing dependencies and try again${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All dependencies satisfied${NC}"

# Run Kubernetes tests
if [[ "$RUN_KUBERNETES" == "true" ]]; then
    if [[ "$QUIET_MODE" == "true" ]]; then
        run_test_suite "Kubernetes" "test-kubernetes-policies.sh" "--ci"
    else
        run_test_suite "Kubernetes" "test-kubernetes-policies.sh" ""
    fi
fi

# Run Terraform tests
if [[ "$RUN_TERRAFORM" == "true" ]]; then
    run_test_suite "Terraform" "test-terraform-policies.sh" ""
fi

# Run Kind cluster tests
if [[ "$RUN_CLUSTER" == "true" ]]; then
    run_test_suite "Kind-Cluster" "test-kind-cluster.sh" ""
fi

# Generate final summary
echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Final Summary${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Add results to summary file
for result in "${TEST_RESULTS[@]}"; do
    IFS='|' read -r suite status duration <<< "$result"
    
    # Determine status icon and color
    if [[ "$status" == "PASS" ]]; then
        status_display="✅ PASS"
        echo -e "${GREEN}✅ $suite: PASS ($duration)${NC}"
    else
        status_display="❌ FAIL"
        echo -e "${RED}❌ $suite: FAIL ($duration)${NC}"
    fi
    
    # Determine report links
    case "$suite" in
        "Kubernetes")
            details="[Summary](../policy-tests/summary.md) | [Details](../policy-tests/detailed-results.md)"
            ;;
        "Terraform")
            details="[Compliant](../terraform-compliance/compliant-plan-scan.md) | [Non-compliant](../terraform-compliance/noncompliant-plan-scan.md)"
            ;;
        "Kind-Cluster")
            details="[Results](../kind-cluster/test-results.md)"
            ;;
        *)
            details="N/A"
            ;;
    esac
    
    echo "| $suite | $status_display | $duration | $details |" >> "$SUMMARY_FILE"
done

# Calculate totals
OVERALL_END=$(date +%s)
OVERALL_DURATION=$((OVERALL_END - OVERALL_START))

# Add summary stats
cat >> "$SUMMARY_FILE" << EOF

## 📈 Statistics

- **Total Duration**: ${OVERALL_DURATION}s
- **Test Suites Run**: ${#TEST_RESULTS[@]}
- **Generated Reports**: $(find "$REPORT_DIR/.." -name "*.md" -type f | wc -l | tr -d ' ')

## 🔍 Key Findings

### Policy Coverage
- Kubernetes policies validated resource compliance
- Terraform policies validated infrastructure as code
- Kind cluster tests validated runtime behavior

### Known Issues
- All policies are in audit mode (logging only, not enforcing)
- This is typical for initial deployment and testing

## 📚 Next Steps

1. Review individual test reports for detailed findings
2. Address any failed tests or policy violations
3. Consider moving policies from audit to enforce mode gradually
4. Implement continuous compliance monitoring

---
*Generated by CIS EKS Kyverno Test Suite v1.0.0*
EOF

# Display summary location
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📁 Comprehensive summary: $SUMMARY_FILE${NC}"
echo -e "${BLUE}⏱️  Total duration: ${OVERALL_DURATION}s${NC}"

# Exit with appropriate code
failed_count=$(printf '%s\n' "${TEST_RESULTS[@]}" | grep -c "FAIL" || true)
if [ "$failed_count" -gt 0 ]; then
    echo -e "\n${RED}❌ $failed_count test suite(s) failed${NC}"
    exit 1
else
    echo -e "\n${GREEN}✅ All test suites passed!${NC}"
    exit 0
fi