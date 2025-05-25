#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

CHECK_MARK="✅"
CROSS_MARK="❌"
WARNING="⚠️"
ROCKET="🚀"
GEAR="⚙️"
CHART="📊"
CLOCK="⏱️"
LIGHTNING="⚡"

REPORT_DIR="reports/policy-tests"
RESULTS_FILE="$REPORT_DIR/detailed-results.md"
SUMMARY_FILE="$REPORT_DIR/summary.md"
STATS_FILE="$REPORT_DIR/execution-stats.json"

mkdir -p "$REPORT_DIR"
rm -f "$RESULTS_FILE" "$SUMMARY_FILE" "$STATS_FILE"

TOTAL_START_TIME=$(date +%s.%N 2>/dev/null || date +%s)
TOTAL_TESTS=0
CURRENT_TEST=0
PASSED=0
FAILED=0
ERRORS=0

show_progress() {
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
    
    local icon=""
    case $status in
        "running") icon="${GEAR}" ;;
        "pass") icon="${CHECK_MARK}" ;;
        "fail") icon="${CROSS_MARK}" ;;
        "error") icon="${WARNING}" ;;
    esac
    
    printf "\r${BLUE}[${bar}]${NC} ${WHITE}%3d%%${NC} ${icon} ${CYAN}%s${NC}" \
           "$percentage" "$test_name"
}

calculate_stats() {
    local test_name=$1
    local start_time=$2
    local end_time=$3
    local result=$4
    
    local duration=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}")
    
    cat >> "$STATS_FILE" << EOF
{
  "test": "$test_name",
  "duration": $duration,
  "result": "$result",
  "timestamp": "$(date -Iseconds)"
},
EOF
}

print_header() {
    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                     ${ROCKET} ${WHITE}Kyverno Policy Test Suite${NC} ${ROCKET}                      ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}${GEAR} System Information:${NC}"
    echo -e "  ${LIGHTNING} Kyverno CLI: $(kyverno version 2>/dev/null | grep Version || echo 'Not detected')"
    echo -e "  ${LIGHTNING} OS: $(uname -s) $(uname -r)"
    echo -e "  ${LIGHTNING} Architecture: $(uname -m)"
    echo -e "  ${LIGHTNING} Test Start: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
}

init_reports() {
    cat > "$RESULTS_FILE" << 'EOF'
# 🧪 Kyverno Policy Test Results

**Comprehensive test results for all CIS EKS compliance policies**

---

## 📊 Executive Summary

| Metric | Value |
|--------|-------|
| **Total Tests** | TOTAL_PLACEHOLDER |
| **✅ Passed** | PASSED_PLACEHOLDER |
| **❌ Failed** | FAILED_PLACEHOLDER |
| **⚠️ Errors** | ERRORS_PLACEHOLDER |
| **Success Rate** | SUCCESS_RATE_PLACEHOLDER |
| **Total Duration** | DURATION_PLACEHOLDER |

---

## 📋 Detailed Test Results

EOF

    cat > "$SUMMARY_FILE" << 'EOF'
# 📈 Policy Test Summary

## 🎯 Test Results Overview

EOF

    echo "[" > "$STATS_FILE"
}

echo -e "${BLUE}${GEAR} Discovering test cases...${NC}"

# Debug: Check if tests directory exists
if [ ! -d "tests/kubernetes" ]; then
    echo -e "${RED}${CROSS_MARK} ERROR: tests/kubernetes directory not found!${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    echo -e "${YELLOW}Contents: $(ls -la)${NC}"
    exit 1
fi

TEST_FILES=($(find tests/kubernetes -type f -name 'kyverno-test.yaml' | sort))
TOTAL_TESTS=${#TEST_FILES[@]}

if [ $TOTAL_TESTS -eq 0 ]; then
    echo -e "${RED}${CROSS_MARK} ERROR: No test files found!${NC}"
    echo -e "${YELLOW}Please ensure test files exist in tests/kubernetes/**/${NC}"
    exit 1
fi

print_header
echo -e "${WHITE}${CHART} Found ${TOTAL_TESTS} test cases to execute${NC}"
echo

init_reports

FASTEST_TEST=""
SLOWEST_TEST=""
FASTEST_TIME=999999
SLOWEST_TIME=0

for testfile in "${TEST_FILES[@]}"; do
    ((CURRENT_TEST++))
    
    TEST_NAME=$(echo "$testfile" | sed 's|tests/kubernetes/||' | sed 's|/[^/]*$||')
    
    show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "running"
    
    TEST_START_TIME=$(date +%s.%N 2>/dev/null || date +%s)
    
    echo "\n## 🧪 Test: \`$testfile\`" >> "$RESULTS_FILE"
    echo "**Started:** $(date '+%H:%M:%S')" >> "$RESULTS_FILE"
    PROGRESS_PERCENT=$(awk "BEGIN {printf \"%.1f\", $CURRENT_TEST * 100 / $TOTAL_TESTS}")
    echo "**Progress:** ${CURRENT_TEST}/${TOTAL_TESTS} (${PROGRESS_PERCENT}%)" >> "$RESULTS_FILE"
    
    set +e
    TEST_OUT=$(kyverno test "$(dirname "$testfile")" 2>&1)
    TEST_EXIT_CODE=$?
    set -e
    
    TEST_END_TIME=$(date +%s.%N 2>/dev/null || date +%s)
    TEST_DURATION=$(awk "BEGIN {printf \"%.3f\", $TEST_END_TIME - $TEST_START_TIME}")
    
    if [ $(awk "BEGIN {print ($TEST_DURATION < $FASTEST_TIME) ? 1 : 0}") -eq 1 ]; then
        FASTEST_TIME=$TEST_DURATION
        FASTEST_TEST=$TEST_NAME
    fi
    if [ $(awk "BEGIN {print ($TEST_DURATION > $SLOWEST_TIME) ? 1 : 0}") -eq 1 ]; then
        SLOWEST_TIME=$TEST_DURATION
        SLOWEST_TEST=$TEST_NAME
    fi
    
    echo "\n**Duration:** ${TEST_DURATION}s" >> "$RESULTS_FILE"
    echo "\n\`\`\`" >> "$RESULTS_FILE"
    echo "$TEST_OUT" >> "$RESULTS_FILE"
    echo "\`\`\`" >> "$RESULTS_FILE"
    
    if [ $TEST_EXIT_CODE -ne 0 ]; then
        show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "error"
        echo "\n❌ **ERROR**: Test command failed with exit code $TEST_EXIT_CODE" >> "$RESULTS_FILE"
        echo "- ❌ \`$testfile\` - **ERROR** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        ((ERRORS++))
        calculate_stats "$TEST_NAME" "$TEST_START_TIME" "$TEST_END_TIME" "error"
    elif echo "$TEST_OUT" | grep -q '\bPass\b'; then
        show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "pass"
        ((PASSED++))
        echo "- ✅ \`$testfile\` - **PASS** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        calculate_stats "$TEST_NAME" "$TEST_START_TIME" "$TEST_END_TIME" "pass"
    elif echo "$TEST_OUT" | grep -q '\bFail\b'; then
        show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "fail"
        ((FAILED++))
        echo "- ❌ \`$testfile\` - **FAIL** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        calculate_stats "$TEST_NAME" "$TEST_START_TIME" "$TEST_END_TIME" "fail"
    elif echo "$TEST_OUT" | grep -q '^Error:'; then
        show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "error"
        ((ERRORS++))
        echo "- ❌ \`$testfile\` - **ERROR** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        calculate_stats "$TEST_NAME" "$TEST_START_TIME" "$TEST_END_TIME" "error"
    else
        show_progress "$CURRENT_TEST" "$TOTAL_TESTS" "$TEST_NAME" "pass"
        ((PASSED++))
        echo "- ✅ \`$testfile\` - **PASS** (${TEST_DURATION}s)" >> "$SUMMARY_FILE"
        calculate_stats "$TEST_NAME" "$TEST_START_TIME" "$TEST_END_TIME" "pass"
    fi
    
    echo "\n---\n" >> "$RESULTS_FILE"
    
    sleep 0.1
done

echo

TOTAL_END_TIME=$(date +%s.%N 2>/dev/null || date +%s)
TOTAL_DURATION=$(awk "BEGIN {printf \"%.3f\", $TOTAL_END_TIME - $TOTAL_START_TIME}")
SUCCESS_RATE=$(awk "BEGIN {printf \"%.1f\", $PASSED * 100 / ($PASSED + $FAILED + $ERRORS)}")
AVG_TEST_TIME=$(awk "BEGIN {printf \"%.3f\", $TOTAL_DURATION / $TOTAL_TESTS}")

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" '$ s/,$//' "$STATS_FILE" 2>/dev/null || true
else
    sed -i '$ s/,$//' "$STATS_FILE" 2>/dev/null || true
fi
echo "]" >> "$STATS_FILE"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

cat >> "$SUMMARY_FILE" << EOF

## 📊 Test Statistics

| Metric | Value |
|--------|-------|
| **Total Tests** | $TOTAL_TESTS |
| **✅ Passed** | $PASSED |
| **❌ Failed** | $FAILED |
| **⚠️ Errors** | $ERRORS |
| **Success Rate** | ${SUCCESS_RATE}% |
| **Total Duration** | ${TOTAL_DURATION}s |
| **Average Test Time** | ${AVG_TEST_TIME}s |

## ⚡ Performance Metrics

| Metric | Test | Time |
|--------|------|------|
| **Fastest** | $FASTEST_TEST | ${FASTEST_TIME}s |
| **Slowest** | $SLOWEST_TEST | ${SLOWEST_TIME}s |

## 🎯 Compliance Overview

EOF

echo "\n### 📊 CIS Section Compliance Breakdown\n" >> "$SUMMARY_FILE"
echo "| Section | Passed | Total | Success Rate | Coverage |" >> "$SUMMARY_FILE"
echo "|---------|--------|-------|--------------|----------|" >> "$SUMMARY_FILE"

for section in 2 3 4 5; do
    SECTION_TOTAL=$(find tests/kubernetes -name "custom-${section}.*" -type d | wc -l | tr -d ' ')
    SECTION_PASSED=$(grep -c "custom-${section}.*PASS" "$SUMMARY_FILE" || echo "0")
    if [ "$SECTION_TOTAL" -gt 0 ]; then
        SECTION_RATE=$(awk "BEGIN {printf \"%.1f\", $SECTION_PASSED * 100 / $SECTION_TOTAL}")
        SECTION_COVERAGE=$(awk "BEGIN {printf \"%.1f\", $SECTION_TOTAL * 100 / 30}")
        echo "| **Section ${section}** | ${SECTION_PASSED} | ${SECTION_TOTAL} | ${SECTION_RATE}% | ${SECTION_COVERAGE}% |" >> "$SUMMARY_FILE"
    fi
done

echo "\n### 🏷️ Policy Type Distribution\n" >> "$SUMMARY_FILE"
CONTROL_PLANE=$(find tests/kubernetes -path "*custom-2.*" -type d | wc -l | tr -d ' ')
WORKER_NODES=$(find tests/kubernetes -path "*custom-3.*" -type d | wc -l | tr -d ' ')
RBAC=$(find tests/kubernetes -path "*custom-4.*" -type d | wc -l | tr -d ' ')
POD_SECURITY=$(find tests/kubernetes -path "*custom-5.*" -type d | wc -l | tr -d ' ')

echo "| Policy Category | Test Count | Percentage |" >> "$SUMMARY_FILE"
echo "|----------------|------------|------------|" >> "$SUMMARY_FILE"
CONTROL_PLANE_PCT=$(awk "BEGIN {printf \"%.1f\", $CONTROL_PLANE * 100 / $TOTAL_TESTS}")
WORKER_NODES_PCT=$(awk "BEGIN {printf \"%.1f\", $WORKER_NODES * 100 / $TOTAL_TESTS}")
RBAC_PCT=$(awk "BEGIN {printf \"%.1f\", $RBAC * 100 / $TOTAL_TESTS}")
POD_SECURITY_PCT=$(awk "BEGIN {printf \"%.1f\", $POD_SECURITY * 100 / $TOTAL_TESTS}")
echo "| Control Plane | $CONTROL_PLANE | ${CONTROL_PLANE_PCT}% |" >> "$SUMMARY_FILE"
echo "| Worker Nodes | $WORKER_NODES | ${WORKER_NODES_PCT}% |" >> "$SUMMARY_FILE"
echo "| RBAC | $RBAC | ${RBAC_PCT}% |" >> "$SUMMARY_FILE"
echo "| Pod Security | $POD_SECURITY | ${POD_SECURITY_PCT}% |" >> "$SUMMARY_FILE"

cat >> "$SUMMARY_FILE" << EOF

## 📅 Test Execution Details

- **Timestamp**: $TIMESTAMP
- **Status**: $( [ $((FAILED+ERRORS)) -eq 0 ] && echo "✅ All tests passed" || echo "❌ Some tests failed" )
- **Test Suite Version**: Enhanced v2.0
- **Execution Mode**: Comprehensive

---

*🤖 Generated by Enhanced Kyverno CIS EKS Compliance Test Suite*
EOF

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/TOTAL_PLACEHOLDER/$TOTAL_TESTS/g" "$RESULTS_FILE"
    sed -i "" "s/PASSED_PLACEHOLDER/$PASSED/g" "$RESULTS_FILE"
    sed -i "" "s/FAILED_PLACEHOLDER/$FAILED/g" "$RESULTS_FILE"
    sed -i "" "s/ERRORS_PLACEHOLDER/$ERRORS/g" "$RESULTS_FILE"
    sed -i "" "s/SUCCESS_RATE_PLACEHOLDER/${SUCCESS_RATE}%/g" "$RESULTS_FILE"
    sed -i "" "s/DURATION_PLACEHOLDER/${TOTAL_DURATION}s/g" "$RESULTS_FILE"
else
    sed -i "s/TOTAL_PLACEHOLDER/$TOTAL_TESTS/g" "$RESULTS_FILE"
    sed -i "s/PASSED_PLACEHOLDER/$PASSED/g" "$RESULTS_FILE"
    sed -i "s/FAILED_PLACEHOLDER/$FAILED/g" "$RESULTS_FILE"
    sed -i "s/ERRORS_PLACEHOLDER/$ERRORS/g" "$RESULTS_FILE"
    sed -i "s/SUCCESS_RATE_PLACEHOLDER/${SUCCESS_RATE}%/g" "$RESULTS_FILE"
    sed -i "s/DURATION_PLACEHOLDER/${TOTAL_DURATION}s/g" "$RESULTS_FILE"
fi

echo
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}                           ${CHART} ${WHITE}FINAL RESULTS${NC} ${CHART}                             ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${WHITE}📊 Test Summary:${NC}"
echo -e "  ${GREEN}✅ Passed:${NC} $PASSED"
echo -e "  ${RED}❌ Failed:${NC} $FAILED"
echo -e "  ${YELLOW}⚠️  Errors:${NC} $ERRORS"
echo -e "  ${CYAN}📈 Success Rate:${NC} ${SUCCESS_RATE}%"
echo
echo -e "${WHITE}⚡ Performance:${NC}"
echo -e "  ${BLUE}⏱️  Total Duration:${NC} ${TOTAL_DURATION}s"
echo -e "  ${BLUE}📊 Average Test Time:${NC} ${AVG_TEST_TIME}s"
echo -e "  ${GREEN}🏃 Fastest Test:${NC} $FASTEST_TEST (${FASTEST_TIME}s)"
echo -e "  ${YELLOW}🐌 Slowest Test:${NC} $SLOWEST_TEST (${SLOWEST_TIME}s)"
echo
echo -e "${WHITE}📋 Reports Generated:${NC}"
echo -e "  ${CYAN}📊 Summary:${NC} $SUMMARY_FILE"
echo -e "  ${CYAN}📋 Detailed:${NC} $RESULTS_FILE"
echo -e "  ${CYAN}📈 Stats:${NC} $STATS_FILE"
echo

if [ $((FAILED+ERRORS)) -gt 0 ]; then
    echo -e "${RED}❌ ERROR: $((FAILED+ERRORS)) test(s) failed!${NC}"
    exit 1
else
    echo -e "${GREEN}${CHECK_MARK} All tests completed successfully!${NC}"
    exit 0
fi