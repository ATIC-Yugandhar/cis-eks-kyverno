#!/bin/bash
# Unified script for testing Kubernetes policies with Kyverno
# Combines functionality from test-all-policies.sh and test-all-policies-ci.sh

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Emoji indicators
CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
ROCKET="🚀"
GEAR="⚙️"
CHART="📊"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_ROOT/reports/policy-tests"
RESULTS_FILE="$REPORT_DIR/detailed-results.md"
SUMMARY_FILE="$REPORT_DIR/summary.md"
STATS_FILE="$REPORT_DIR/execution-stats.json"
CI_MODE="${CI:-false}"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --ci          Run in CI mode (simplified output)"
    echo "  -h, --help        Display this help message"
    echo "  -f, --filter      Filter tests by pattern (e.g., 'custom-5.1')"
    echo ""
    echo "Examples:"
    echo "  $0                     # Run all tests"
    echo "  $0 --ci                # Run in CI mode"
    echo "  $0 --filter custom-5.1 # Run only custom-5.1 tests"
    exit 0
}

# Parse command line arguments
FILTER_PATTERN=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--ci)
            CI_MODE="true"
            shift
            ;;
        -f|--filter)
            FILTER_PATTERN="$2"
            shift 2
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

# Initialize reports
mkdir -p "$REPORT_DIR"
rm -f "$RESULTS_FILE" "$SUMMARY_FILE" "$STATS_FILE"

# Initialize counters
TOTAL_TESTS=0
PASSED=0
FAILED=0
CURRENT_TEST=0
TOTAL_START_TIME=$(date +%s.%N 2>/dev/null || date +%s)

# Function to show progress (only in non-CI mode)
show_progress() {
    if [[ "$CI_MODE" != "true" ]]; then
        local current=$1
        local total=$2
        local test_name=$3
        local status=$4
        
        local percentage=$((current * 100 / total))
        local filled=$((percentage / 2))
        local empty=$((50 - filled))
        
        local bar=""
        for ((i=0; i<filled; i++)); do bar+="█"; done
        for ((i=0; i<empty; i++)); do bar+="░"; done
        
        local status_icon
        case "$status" in
            "running") status_icon="${GEAR} Running" ;;
            "passed") status_icon="${CHECK_MARK} Passed" ;;
            "failed") status_icon="${CROSS_MARK} Failed" ;;
            "error") status_icon="${WARNING} Error" ;;
        esac
        
        printf "\r${CYAN}[%s] %3d%% ${NC}%-50s %s" "$bar" "$percentage" "$test_name" "$status_icon"
        
        if [[ "$status" != "running" ]]; then
            echo
        fi
    fi
}

# Check dependencies
echo -e "${BLUE}${GEAR} Checking dependencies...${NC}"
if ! command -v kyverno &> /dev/null; then
    echo -e "${RED}${CROSS_MARK} Error: kyverno CLI not found. Please install it first.${NC}"
    exit 1
fi

# Display Kyverno version
echo -e "${GREEN}${CHECK_MARK} Using Kyverno version: $(kyverno version 2>&1 | grep -E "Version:|version:" | head -1)${NC}"

# Find test files
echo -e "${BLUE}${ROCKET} Discovering test files...${NC}"
if [[ -n "$FILTER_PATTERN" ]]; then
    TEST_FILES=($(find "$PROJECT_ROOT/tests/kubernetes" -type f -name 'kyverno-test.yaml' | grep "$FILTER_PATTERN" | sort))
else
    TEST_FILES=($(find "$PROJECT_ROOT/tests/kubernetes" -type f -name 'kyverno-test.yaml' | sort))
fi

TOTAL_TESTS=${#TEST_FILES[@]}

if [ "$TOTAL_TESTS" -eq 0 ]; then
    echo -e "${YELLOW}${WARNING} No test files found${NC}"
    exit 0
fi

echo -e "${GREEN}${CHECK_MARK} Found $TOTAL_TESTS test files${NC}"

# Initialize report files
cat > "$RESULTS_FILE" << EOF
# Kyverno Policy Test Results

## Test Execution Details

EOF

echo "# Kyverno Policy Test Summary" > "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "## Test Results" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Main test loop
echo -e "\n${BLUE}${ROCKET} Running tests...${NC}\n"

for testfile in "${TEST_FILES[@]}"; do
    ((CURRENT_TEST++))
    TEST_NAME=$(echo "$testfile" | sed 's|.*/tests/kubernetes/||' | sed 's|/kyverno-test.yaml$||')
    
    # Show progress
    if [[ "$CI_MODE" == "true" ]]; then
        echo "Running test $CURRENT_TEST/$TOTAL_TESTS: $TEST_NAME"
    else
        show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "running"
    fi
    
    # Run test using wrapper if available
    TEST_START=$(date +%s.%N 2>/dev/null || date +%s)
    
    if [ -f "$SCRIPT_DIR/kyverno-test-wrapper.sh" ]; then
        TEST_OUT=$("$SCRIPT_DIR/kyverno-test-wrapper.sh" "$(dirname "$testfile")" 2>&1)
        TEST_EXIT=$?
    else
        TEST_OUT=$(kyverno test "$(dirname "$testfile")" 2>&1)
        TEST_EXIT=$?
    fi
    
    TEST_END=$(date +%s.%N 2>/dev/null || date +%s)
    TEST_DURATION=$(awk "BEGIN {printf \"%.3f\", $TEST_END - $TEST_START}")
    
    # Record results
    echo "### Test: $testfile" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "$TEST_OUT" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    # Update counters and summary
    if [ $TEST_EXIT -eq 0 ]; then
        ((PASSED++))
        echo "- ✅ \`$TEST_NAME\` - **PASS** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        if [[ "$CI_MODE" == "true" ]]; then
            echo "  ✓ PASSED"
        else
            show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "passed"
        fi
    else
        ((FAILED++))
        echo "- ❌ \`$TEST_NAME\` - **FAIL** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        if [[ "$CI_MODE" == "true" ]]; then
            echo "  ✗ FAILED"
        else
            show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "failed"
        fi
    fi
done

# Calculate statistics
TOTAL_END_TIME=$(date +%s.%N 2>/dev/null || date +%s)
TOTAL_DURATION=$(awk "BEGIN {printf \"%.3f\", $TOTAL_END_TIME - $TOTAL_START_TIME}")
SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", $PASSED * 100 / $TOTAL_TESTS}")

# Write statistics file
cat > "$STATS_FILE" << EOF
{
  "total_tests": $TOTAL_TESTS,
  "passed": $PASSED,
  "failed": $FAILED,
  "success_rate": "$SUCCESS_RATE%",
  "total_duration": "${TOTAL_DURATION}s",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

# Display summary
echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${CHART} Test Summary${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total Tests:    $TOTAL_TESTS"
echo -e "${GREEN}Passed:         $PASSED${NC}"
echo -e "${RED}Failed:         $FAILED${NC}"
echo -e "Success Rate:   $SUCCESS_RATE%"
echo -e "Duration:       ${TOTAL_DURATION}s"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Report locations
echo -e "\n${BLUE}📁 Reports generated:${NC}"
echo -e "  - Summary: $SUMMARY_FILE"
echo -e "  - Details: $RESULTS_FILE"
echo -e "  - Stats:   $STATS_FILE"

# Exit with appropriate code
if [ "$FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi