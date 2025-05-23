#!/bin/bash
set -e

REPORT_DIR="reports"
SUMMARY_FILE="$REPORT_DIR/executive-summary.md"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

cat > "$SUMMARY_FILE" << EOF
# Kyverno CIS EKS Compliance Test Report
Generated: $TIMESTAMP

## Test Results Summary

### 1. Policy Unit Tests
EOF

if [ -f "$REPORT_DIR/policy-tests/summary.txt" ]; then
    echo "```" >> "$SUMMARY_FILE"
    tail -n 10 "$REPORT_DIR/policy-tests/summary.txt" | grep -E "(Total|Passed|Failed|Errors)" >> "$SUMMARY_FILE" || echo "No summary available" >> "$SUMMARY_FILE"
    echo "```" >> "$SUMMARY_FILE"
else
    echo "- No policy test results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 2. Terraform Compliance Tests
EOF

if [ -f "$REPORT_DIR/terraform-compliance/compliant-plan-scan.yaml" ] && [ -f "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.yaml" ]; then
    echo "- Compliant configuration scan: ✓ Completed" >> "$SUMMARY_FILE"
    echo "- Non-compliant configuration scan: ✓ Completed" >> "$SUMMARY_FILE"
    
    VIOLATIONS=$(grep -c "fail" "$REPORT_DIR/terraform-compliance/noncompliant-plan-scan.yaml" 2>/dev/null || echo "0")
    echo "- Policy violations detected in non-compliant config: $VIOLATIONS" >> "$SUMMARY_FILE"
else
    echo "- No terraform compliance results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 3. Integration Tests (Kind Cluster)
EOF

if [ -f "$REPORT_DIR/integration-tests/cluster-scan.yaml" ]; then
    echo "- Cluster scan: ✓ Completed" >> "$SUMMARY_FILE"
    echo "- Policy validation: ✓ Completed" >> "$SUMMARY_FILE"
else
    echo "- No integration test results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

## Report Files

### Policy Tests
- Detailed results: \`reports/policy-tests/detailed-results.txt\`
- Summary: \`reports/policy-tests/summary.txt\`

### Terraform Compliance
- Compliant scan: \`reports/terraform-compliance/compliant-plan-scan.yaml\`
- Non-compliant scan: \`reports/terraform-compliance/noncompliant-plan-scan.yaml\`

### Integration Tests
- Policy application: \`reports/integration-tests/policy-application.yaml\`
- Cluster scan: \`reports/integration-tests/cluster-scan.yaml\`

---
*End of Report*
EOF

echo "Executive summary generated: $SUMMARY_FILE"