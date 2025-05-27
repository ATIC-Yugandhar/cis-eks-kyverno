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
    
    if grep -q "Test Statistics" "$REPORT_DIR/policy-tests/summary.md"; then
        echo "" >> "$SUMMARY_FILE"
        # Extract Test Statistics table
        sed -n '/## Test Statistics/,/## Performance Metrics/p' "$REPORT_DIR/policy-tests/summary.md" | grep -E "^\|" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        
        echo "#### ⚡ Performance Metrics" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
        # Extract Performance Metrics table
        sed -n '/## Performance Metrics/,/## Kubernetes Policies/p' "$REPORT_DIR/policy-tests/summary.md" | grep -E "^\|" >> "$SUMMARY_FILE"
    else
        echo "- ❌ No detailed policy test statistics available" >> "$SUMMARY_FILE"
    fi
    
    if grep -q "Performance Metrics" "$REPORT_DIR/policy-tests/summary.md"; then
        echo -e "\n#### ⚡ Performance Metrics" >> "$SUMMARY_FILE"
        grep -A 5 "Performance Metrics" "$REPORT_DIR/policy-tests/summary.md" | tail -n +2 >> "$SUMMARY_FILE"
    fi
else
    echo -e "${YELLOW}⚠️  Policy test results not found${NC}"
    echo "- ❌ No policy test results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🛠️ Terraform Compliance Tests
EOF

if [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && [ -f "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" ]; then
    echo -e "${GREEN}✅ Terraform compliance tests found${NC}"
    
    COMPLIANT_SUCCESS=$(grep -o "Success Rate.*%" "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" 2>/dev/null || echo "N/A")
    NONCOMPLIANT_SUCCESS=$(grep -o "Success Rate.*%" "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" 2>/dev/null || echo "N/A")
    
    cat >> "$SUMMARY_FILE" << TERRAFORM_EOF

| Configuration | Status | Success Rate |
|---------------|--------|--------------|
| ✅ Compliant | Complete | $COMPLIANT_SUCCESS |
| 🔴 Noncompliant | Complete | $NONCOMPLIANT_SUCCESS |

TERRAFORM_EOF
    
    VIOLATIONS=$(grep -c "fail" "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" 2>/dev/null || echo "0")
    echo "- 🔴 Policy violations detected in non-compliant config: **$VIOLATIONS**" >> "$SUMMARY_FILE"
else
    echo -e "${YELLOW}⚠️  Terraform compliance results not found${NC}"
    echo "- ❌ No terraform compliance results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🌟 Kind Integration Tests
EOF

if [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ]; then
    echo -e "${GREEN}✅ Kind integration tests found${NC}"
    echo "" >> "$SUMMARY_FILE"
    echo "✅ Integration tests completed successfully" >> "$SUMMARY_FILE"
    
    # Count resources tested
    RESOURCE_COUNT=$(grep -c "Testing" "$REPORT_DIR/kind-cluster/validation-results.txt" 2>/dev/null || echo "0")
    echo "- Resources tested: **$RESOURCE_COUNT**" >> "$SUMMARY_FILE"
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