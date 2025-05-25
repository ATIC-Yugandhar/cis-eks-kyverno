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

TOTAL_REPORTS=0
COMPLETE_REPORTS=0

cat > "$SUMMARY_FILE" << EOF
# 📋 Kyverno CIS EKS Compliance Executive Summary

**Generated**: $TIMESTAMP

## 🎯 Executive Overview

| Metric | Value |
|--------|-------|
| **Total Test Suites** | TOTAL_SUITES_PLACEHOLDER |
| **✅ Completed Suites** | COMPLETED_SUITES_PLACEHOLDER |
| **Completion Rate** | COMPLETION_RATE_PLACEHOLDER |
| **Generation Time** | $TIMESTAMP |

---

## 📈 Detailed Test Results

### 📋 Policy Unit Tests
EOF

((TOTAL_REPORTS++))
if [ -f "$REPORT_DIR/policy-tests/summary.md" ]; then
    ((COMPLETE_REPORTS++))
    echo -e "${GREEN}✅ Policy tests found${NC}"
    
    if grep -q "Test Statistics" "$REPORT_DIR/policy-tests/summary.md"; then
        echo "" >> "$SUMMARY_FILE"
        grep -A 10 "Test Statistics" "$REPORT_DIR/policy-tests/summary.md" | head -n 11 >> "$SUMMARY_FILE"
    else
        echo "- ❌ No detailed policy test statistics available" >> "$SUMMARY_FILE"
    fi
    
    if grep -q "Performance Metrics" "$REPORT_DIR/policy-tests/summary.md"; then
        echo "\n#### ⚡ Performance Metrics" >> "$SUMMARY_FILE"
        grep -A 5 "Performance Metrics" "$REPORT_DIR/policy-tests/summary.md" | tail -n +2 >> "$SUMMARY_FILE"
    fi
else
    echo -e "${YELLOW}⚠️  Policy test results not found${NC}"
    echo "- ❌ No policy test results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🛠️ Terraform Compliance Tests
EOF

((TOTAL_REPORTS++))
if [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && [ -f "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.md" ]; then
    ((COMPLETE_REPORTS++))
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

if [ $TOTAL_REPORTS -gt 0 ]; then
    COMPLETION_RATE=$(awk "BEGIN {printf \"%.1f\", $COMPLETE_REPORTS * 100 / $TOTAL_REPORTS}")
else
    COMPLETION_RATE="0.0"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i "" "s/TOTAL_SUITES_PLACEHOLDER/$TOTAL_REPORTS/g" "$SUMMARY_FILE"
    sed -i "" "s/COMPLETED_SUITES_PLACEHOLDER/$COMPLETE_REPORTS/g" "$SUMMARY_FILE"
    sed -i "" "s/COMPLETION_RATE_PLACEHOLDER/${COMPLETION_RATE}%/g" "$SUMMARY_FILE"
else
    sed -i "s/TOTAL_SUITES_PLACEHOLDER/$TOTAL_REPORTS/g" "$SUMMARY_FILE"
    sed -i "s/COMPLETED_SUITES_PLACEHOLDER/$COMPLETE_REPORTS/g" "$SUMMARY_FILE"
    sed -i "s/COMPLETION_RATE_PLACEHOLDER/${COMPLETION_RATE}%/g" "$SUMMARY_FILE"
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

### 📈 Infrastructure Validation
- **Compliant summary**: [✅ compliant-summary.md](compliance/compliant-summary.md)
- **Noncompliant summary**: [🔴 noncompliant-summary.md](compliance/noncompliant-summary.md)

---

## 📈 Test Suite Status

| Test Suite | Status | Completion | Notes |
|------------|--------|------------|-------|
| Policy Unit Tests | $( [ -f "$REPORT_DIR/policy-tests/summary.md" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/policy-tests/summary.md" ] && echo "100%" || echo "0%" ) | Kubernetes policy validation |
| Terraform Compliance | $( [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.md" ] && echo "100%" || echo "0%" ) | Infrastructure compliance |
| **Overall** | **${COMPLETION_RATE}%** | **${COMPLETE_REPORTS}/${TOTAL_REPORTS}** | **Test suite completion** |

---

*🤖 Generated by Enhanced Kyverno CIS EKS Compliance Test Suite v2.0*
EOF

echo -e "${GREEN}✅ Executive summary generated successfully!${NC}"
echo -e "${BLUE}📈 Completion rate: ${COMPLETION_RATE}% (${COMPLETE_REPORTS}/${TOTAL_REPORTS} suites)${NC}"
echo -e "${BLUE}📁 Report location: $SUMMARY_FILE${NC}"