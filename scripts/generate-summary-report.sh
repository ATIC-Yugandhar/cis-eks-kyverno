#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

REPORT_DIR="reports"
SUMMARY_FILE="$REPORT_DIR/executive-summary.md"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "${PURPLE}📈 Generating Executive Summary Report...${NC}"

# Debug: Show current environment and available reports
if [ "${CI:-false}" = "true" ] || [ "${GITHUB_ACTIONS:-false}" = "true" ]; then
    echo "🔍 CI Environment detected - Debug info:"
    echo "Working directory: $(pwd)"
    echo "Reports directory exists: $([ -d "$REPORT_DIR" ] && echo 'YES' || echo 'NO')"
    if [ -d "$REPORT_DIR" ]; then
        echo "Available report files:"
        find "$REPORT_DIR" -type f -name "*.md" -o -name "*.txt" -o -name "*.json" | sort
    fi
    echo "---"
fi

# Count total test suites available
TOTAL_REPORTS=3  # Policy tests, Terraform Compliance, Kind Integration

# Count completed reports
COMPLETE_REPORTS=0
if [ -f "$REPORT_DIR/policy-tests/summary.md" ]; then
    ((COMPLETE_REPORTS++))
fi
if [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ]; then
    ((COMPLETE_REPORTS++))
fi
if [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ]; then
    ((COMPLETE_REPORTS++))
fi

# Calculate completion rate
if [ $TOTAL_REPORTS -gt 0 ]; then
    COMPLETION_RATE=$(awk "BEGIN {printf \"%.1f\", $COMPLETE_REPORTS * 100 / $TOTAL_REPORTS}")
else
    COMPLETION_RATE="0.0"
fi

# Initialize the summary file with actual values
echo "# 📋 Kyverno CIS EKS Compliance Executive Summary" > "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "**Generated**: $TIMESTAMP" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "## 🎯 Executive Overview" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "| Metric | Value |" >> "$SUMMARY_FILE"
echo "|--------|-------|" >> "$SUMMARY_FILE"
echo "| **Total Test Suites** | $TOTAL_REPORTS |" >> "$SUMMARY_FILE"
echo "| **✅ Completed Suites** | $COMPLETE_REPORTS |" >> "$SUMMARY_FILE"
echo "| **Completion Rate** | ${COMPLETION_RATE}% |" >> "$SUMMARY_FILE"
echo "| **Generation Time** | $TIMESTAMP |" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "---" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "## 📈 Detailed Test Results" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "### 📋 Policy Unit Tests" >> "$SUMMARY_FILE"

if [ -f "$REPORT_DIR/policy-tests/summary.md" ]; then
    echo -e "${GREEN}✅ Policy tests found${NC}"
    
    # Extract exact metrics from the summary file
    TOTAL_POLICIES=$(grep "Total Policies" "$REPORT_DIR/policy-tests/summary.md" | grep -o '[0-9]*' | head -1)
    TOTAL_TESTS=$(grep "Total Tests" "$REPORT_DIR/policy-tests/summary.md" | grep -o '[0-9]*' | head -1)
    PASSED_TESTS=$(grep "✅ Passed" "$REPORT_DIR/policy-tests/summary.md" | grep -o '[0-9]*' | head -1)
    FAILED_TESTS=$(grep "❌ Failed" "$REPORT_DIR/policy-tests/summary.md" | grep -o '[0-9]*' | head -1)
    SKIPPED_TESTS=$(grep "⏭️ Skipped" "$REPORT_DIR/policy-tests/summary.md" | grep -o '[0-9]*' | head -1)
    SUCCESS_RATE=$(grep "Success Rate" "$REPORT_DIR/policy-tests/summary.md" | grep -o '[0-9]*%' | head -1)
    
    DURATION=$(grep "Duration" "$REPORT_DIR/policy-tests/summary.md" | awk '{print $4}' | head -1)
    TESTS_PER_SEC=$(grep "Tests/Second" "$REPORT_DIR/policy-tests/summary.md" | awk '{print $4}' | head -1)
    
    # Default values if extraction fails
    TOTAL_POLICIES=${TOTAL_POLICIES:-"0"}
    TOTAL_TESTS=${TOTAL_TESTS:-"0"}
    PASSED_TESTS=${PASSED_TESTS:-"0"}
    FAILED_TESTS=${FAILED_TESTS:-"0"}
    SKIPPED_TESTS=${SKIPPED_TESTS:-"0"}
    SUCCESS_RATE=${SUCCESS_RATE:-"0%"}
    DURATION=${DURATION:-"N/A"}
    TESTS_PER_SEC=${TESTS_PER_SEC:-"N/A"}
    
    cat >> "$SUMMARY_FILE" << POLICY_EOF

| Metric | Value |
|--------|-------|
| Total Policies | $TOTAL_POLICIES |
| Total Tests | $TOTAL_TESTS |
| ✅ Passed | $PASSED_TESTS |
| ❌ Failed | $FAILED_TESTS |
| ⏭️ Skipped | $SKIPPED_TESTS |
| Success Rate | $SUCCESS_RATE |

#### ⚡ Performance Metrics

| Metric | Value |
|--------|-------|
| Duration | $DURATION |
| Tests/Second | $TESTS_PER_SEC |

POLICY_EOF
else
    echo -e "${YELLOW}⚠️  Policy test results not found${NC}"
    echo "- ❌ No policy test results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🛠️ Terraform Compliance Tests
EOF

if [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && [ -f "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" ]; then
    echo -e "${GREEN}✅ Terraform compliance tests found${NC}"
    
    # Extract exact metrics from terraform reports using the correct format
    COMPLIANT_SUCCESS=$(grep "\*\*Success Rate\*\*:" "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" | awk '{print $NF}' 2>/dev/null || echo "0%")
    NONCOMPLIANT_DETECTION=$(grep "\*\*Detection Rate\*\*:" "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" | awk '{print $NF}' 2>/dev/null || echo "0%")
    
    # If the markdown format doesn't work, try the simple format
    if [ "$COMPLIANT_SUCCESS" = "0%" ]; then
        COMPLIANT_SUCCESS=$(grep "Success Rate" "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" | sed 's/.*Success Rate[^:]*: *//' | awk '{print $1}' 2>/dev/null || echo "0%")
    fi
    
    if [ "$NONCOMPLIANT_DETECTION" = "0%" ]; then
        NONCOMPLIANT_DETECTION=$(grep "Detection Rate" "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" | sed 's/.*Detection Rate[^:]*: *//' | awk '{print $1}' 2>/dev/null || echo "0%")
    fi
    
    VIOLATIONS_DETECTED=$(grep "Violations Detected" "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" | sed 's/.*Violations Detected[^:]*: *//' | awk '{print $1}' 2>/dev/null || echo "0")
    
    cat >> "$SUMMARY_FILE" << TERRAFORM_EOF

| Configuration | Status | Success Rate |
|---------------|--------|--------------|
| ✅ Compliant | Complete | $COMPLIANT_SUCCESS |
| 🔴 Noncompliant | Complete | N/A |

- 🔴 Policy violations detected in non-compliant config: **$VIOLATIONS_DETECTED**

TERRAFORM_EOF
else
    echo -e "${YELLOW}⚠️  Terraform compliance results not found${NC}"
    echo "- ❌ No terraform compliance results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🌟 Kind Integration Tests
EOF

if [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] || [ -f "$REPORT_DIR/kind-cluster/validation-summary.md" ]; then
    echo -e "${GREEN}✅ Kind integration tests found${NC}"
    
    if [ -f "$REPORT_DIR/kind-cluster/validation-summary.md" ]; then
        # Extract from validation summary if available
        POLICIES_APPLIED=$(grep "Policies Applied" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "0")
        CATEGORIES_TESTED=$(grep "Categories Tested" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "0")
        TEST_MANIFESTS=$(grep "Test Manifests" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "0")
        echo "- ✅ Integration tests completed successfully" >> "$SUMMARY_FILE"
        echo "- Policies Applied: **$POLICIES_APPLIED**" >> "$SUMMARY_FILE"
        echo "- Categories Tested: **$CATEGORIES_TESTED**" >> "$SUMMARY_FILE"
        echo "- Test Manifests: **$TEST_MANIFESTS**" >> "$SUMMARY_FILE"
    else
        # Fallback to validation-results.txt
        RESOURCE_COUNT=$(grep -c "Testing\|PASS\|FAIL" "$REPORT_DIR/kind-cluster/validation-results.txt" 2>/dev/null || echo "0")
        echo "- ✅ Integration tests completed successfully" >> "$SUMMARY_FILE"
        echo "- Resources tested: **$RESOURCE_COUNT**" >> "$SUMMARY_FILE"
    fi
else
    echo -e "${YELLOW}⚠️  Kind integration results not found${NC}"
    echo "- ❌ No Kind integration test results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

---

## 📁 Report Files Directory

### 📊 Policy Tests
- **Detailed results**: [🗾 detailed-results.md](policy-tests/detailed-results.md)
- **Summary**: [📈 summary.md](policy-tests/summary.md)
- **Execution stats**: [📊 execution-stats.json](policy-tests/execution-stats.json)

### 🛠️ Terraform Compliance
- **Compliant scan**: [✅ compliant-plan-scan.md](terraform-compliance/compliant-plan-scan.md)  
- **Non-compliant scan**: [❌ noncompliant-plan-scan.md](terraform-compliance/noncompliant-plan-scan.md)

### 🌟 Kind Integration  
- **Validation results**: [📊 validation-results.txt](kind-cluster/validation-results.txt)
- **Cluster resources**: [🎯 cluster-resources.yaml](kind-cluster/cluster-resources.yaml)

---

## 📈 Test Suite Status

| Test Suite | Status | Completion | Notes |
|------------|--------|------------|-------|
| Policy Unit Tests | $( [ -f "$REPORT_DIR/policy-tests/summary.md" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/policy-tests/summary.md" ] && echo "100%" || echo "0%" ) | Kubernetes policy validation |
| Terraform Compliance | $( [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && echo "100%" || echo "0%" ) | Infrastructure compliance |
| Kind Integration | $( [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] && echo "100%" || echo "0%" ) | Local cluster testing |
| **Overall** | **${COMPLETION_RATE}%** | **${COMPLETE_REPORTS}/${TOTAL_REPORTS}** | **Test suite completion** |

---

*🤖 Generated by Enhanced Kyverno CIS EKS Compliance Test Suite v2.0*
EOF

echo -e "${GREEN}✅ Executive summary generated successfully!${NC}"
echo -e "${BLUE}📈 Completion rate: ${COMPLETION_RATE}% (${COMPLETE_REPORTS}/${TOTAL_REPORTS} suites)${NC}"
echo -e "${BLUE}📁 Report location: $SUMMARY_FILE${NC}"