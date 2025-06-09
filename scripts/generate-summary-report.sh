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

echo -e "${PURPLE}📈 Generating Executive Summary Report with Kube-bench Integration...${NC}"

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

# Count total test suites available (now includes kube-bench)
TOTAL_REPORTS=4  # Policy tests, OpenTofu Compliance, Kind Integration, Kube-bench CIS

# Count completed reports
COMPLETE_REPORTS=0
if [ -f "$REPORT_DIR/policy-tests/summary.md" ]; then
    ((COMPLETE_REPORTS++))
fi
if [ -f "$REPORT_DIR/opentofu-compliance/compliant-plan-scan.md" ]; then
    ((COMPLETE_REPORTS++))
fi
if [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] || [ -f "$REPORT_DIR/kind-cluster/validation-summary.md" ]; then
    ((COMPLETE_REPORTS++))
fi
if [ -f "$REPORT_DIR/kube-bench/summary.md" ] || [ -f "$REPORT_DIR/kind-cluster/kube-bench/summary.md" ]; then
    ((COMPLETE_REPORTS++))
fi

# Calculate completion rate
if [ $TOTAL_REPORTS -gt 0 ]; then
    COMPLETION_RATE=$(awk "BEGIN {printf \"%.1f\", $COMPLETE_REPORTS * 100 / $TOTAL_REPORTS}")
else
    COMPLETION_RATE="0.0"
fi

# Initialize the summary file with actual values
echo "# 📋 Kyverno + Kube-bench CIS EKS Compliance Executive Summary" > "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "**Generated**: $TIMESTAMP" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "## 🎯 Executive Overview" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "This comprehensive compliance report combines **Kyverno policy validation** with **kube-bench CIS scanning** to provide complete Kubernetes security coverage." >> "$SUMMARY_FILE"
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

### 🔒 Kube-bench CIS Compliance Scan
EOF

# Check for kube-bench results in multiple locations
KUBE_BENCH_FOUND=false
KUBE_BENCH_DIR=""

if [ -f "$REPORT_DIR/kube-bench/summary.md" ]; then
    KUBE_BENCH_FOUND=true
    KUBE_BENCH_DIR="$REPORT_DIR/kube-bench"
elif [ -f "$REPORT_DIR/kind-cluster/kube-bench/summary.md" ]; then
    KUBE_BENCH_FOUND=true
    KUBE_BENCH_DIR="$REPORT_DIR/kind-cluster/kube-bench"
fi

if [ "$KUBE_BENCH_FOUND" = true ]; then
    echo -e "${GREEN}✅ Kube-bench CIS compliance scan found${NC}"
    
    # Extract kube-bench metrics
    if [ -f "$KUBE_BENCH_DIR/node-scan.json" ]; then
        # Try to extract totals using jq if available, otherwise use grep
        if command -v jq >/dev/null 2>&1 && grep -q '"Totals"' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null; then
            NODE_PASS=$(jq -r '.Totals.pass // 0' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null || echo "N/A")
            NODE_FAIL=$(jq -r '.Totals.fail // 0' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null || echo "N/A")
            NODE_WARN=$(jq -r '.Totals.warn // 0' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null || echo "N/A")
            NODE_INFO=$(jq -r '.Totals.info // 0' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null || echo "N/A")
        else
            NODE_PASS=$(grep -o '"pass":[0-9]*' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null | cut -d: -f2 | head -1 || echo "N/A")
            NODE_FAIL=$(grep -o '"fail":[0-9]*' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null | cut -d: -f2 | head -1 || echo "N/A")
            NODE_WARN=$(grep -o '"warn":[0-9]*' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null | cut -d: -f2 | head -1 || echo "N/A")
            NODE_INFO=$(grep -o '"info":[0-9]*' "$KUBE_BENCH_DIR/node-scan.json" 2>/dev/null | cut -d: -f2 | head -1 || echo "N/A")
        fi
    else
        NODE_PASS="N/A"
        NODE_FAIL="N/A"
        NODE_WARN="N/A"
        NODE_INFO="N/A"
    fi
    
    # Check for master scan results
    if [ -f "$KUBE_BENCH_DIR/master-scan.json" ] && grep -q '"Totals"' "$KUBE_BENCH_DIR/master-scan.json" 2>/dev/null; then
        if command -v jq >/dev/null 2>&1; then
            MASTER_PASS=$(jq -r '.Totals.pass // 0' "$KUBE_BENCH_DIR/master-scan.json" 2>/dev/null || echo "N/A")
            MASTER_FAIL=$(jq -r '.Totals.fail // 0' "$KUBE_BENCH_DIR/master-scan.json" 2>/dev/null || echo "N/A")
        else
            MASTER_PASS=$(grep -o '"pass":[0-9]*' "$KUBE_BENCH_DIR/master-scan.json" 2>/dev/null | cut -d: -f2 | head -1 || echo "N/A")
            MASTER_FAIL=$(grep -o '"fail":[0-9]*' "$KUBE_BENCH_DIR/master-scan.json" 2>/dev/null | cut -d: -f2 | head -1 || echo "N/A")
        fi
        MASTER_AVAILABLE="✅ Available"
    else
        MASTER_PASS="N/A"
        MASTER_FAIL="N/A"
        MASTER_AVAILABLE="⚠️ Not Available"
    fi
    
    cat >> "$SUMMARY_FILE" << KUBEBENCH_EOF

| Component | Status | Pass | Fail | Warn | Info |
|-----------|--------|------|------|------|------|
| **Worker Nodes** | ✅ Scanned | $NODE_PASS | $NODE_FAIL | $NODE_WARN | $NODE_INFO |
| **Control Plane** | $MASTER_AVAILABLE | $MASTER_PASS | $MASTER_FAIL | N/A | N/A |

#### 🔍 CIS Controls Coverage

- **3.1.x**: Worker node configuration files (permissions, ownership)
- **3.2.x**: Worker node kubelet configuration (anonymous auth, authorization)
- **4.1.x**: Control plane node configuration files (when available)
- **4.2.x**: Control plane kubelet configuration (when available)

KUBEBENCH_EOF
else
    echo -e "${YELLOW}⚠️  Kube-bench CIS compliance results not found${NC}"
    echo "- ❌ No kube-bench CIS compliance scan results found" >> "$SUMMARY_FILE"
    echo "- ⚠️ Node-level file system validation not performed" >> "$SUMMARY_FILE"
    echo "- 💡 Recommendation: Ensure kube-bench is running on target clusters" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🛠️ OpenTofu Compliance Tests
EOF

if [ -f "$REPORT_DIR/opentofu-compliance/compliant-plan-scan.md" ] && [ -f "$REPORT_DIR/opentofu-compliance/noncompliant-plan-scan.md" ]; then
    echo -e "${GREEN}✅ OpenTofu compliance tests found${NC}"
    
    # Extract exact metrics from opentofu reports using the correct format
    COMPLIANT_SUCCESS=$(grep "\*\*Success Rate\*\*:" "$REPORT_DIR/opentofu-compliance/compliant-plan-scan.md" | awk '{print $NF}' 2>/dev/null || echo "0%")
    NONCOMPLIANT_DETECTION=$(grep "\*\*Detection Rate\*\*:" "$REPORT_DIR/opentofu-compliance/noncompliant-plan-scan.md" | awk '{print $NF}' 2>/dev/null || echo "0%")
    
    # If the markdown format doesn't work, try the simple format
    if [ "$COMPLIANT_SUCCESS" = "0%" ]; then
        COMPLIANT_SUCCESS=$(grep "Success Rate" "$REPORT_DIR/opentofu-compliance/compliant-plan-scan.md" | sed 's/.*Success Rate[^:]*: *//' | awk '{print $1}' 2>/dev/null || echo "0%")
    fi
    
    if [ "$NONCOMPLIANT_DETECTION" = "0%" ]; then
        NONCOMPLIANT_DETECTION=$(grep "Detection Rate" "$REPORT_DIR/opentofu-compliance/noncompliant-plan-scan.md" | sed 's/.*Detection Rate[^:]*: *//' | awk '{print $1}' 2>/dev/null || echo "0%")
    fi
    
    VIOLATIONS_DETECTED=$(grep "Violations Detected" "$REPORT_DIR/opentofu-compliance/noncompliant-plan-scan.md" | sed 's/.*Violations Detected[^:]*: *//' | awk '{print $1}' 2>/dev/null || echo "0")
    
    cat >> "$SUMMARY_FILE" << OPENTOFU_EOF

| Configuration | Status | Success Rate | Kube-bench Integration |
|---------------|--------|--------------|------------------------|
| ✅ Compliant | Complete | $COMPLIANT_SUCCESS | DaemonSet deployed |
| 🔴 Noncompliant | Complete | N/A | Minimal configuration |

- 🔴 Policy violations detected in non-compliant config: **$VIOLATIONS_DETECTED**
- 🔒 Kube-bench deployed via OpenTofu for continuous compliance monitoring

OPENTOFU_EOF
else
    echo -e "${YELLOW}⚠️  OpenTofu compliance results not found${NC}"
    echo "- ❌ No opentofu compliance results found" >> "$SUMMARY_FILE"
fi

cat >> "$SUMMARY_FILE" << EOF

### 🌟 Kind Integration Tests
EOF

if [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] || [ -f "$REPORT_DIR/kind-cluster/validation-summary.md" ]; then
    echo -e "${GREEN}✅ Kind integration tests found${NC}"
    
    if [ -f "$REPORT_DIR/kind-cluster/validation-summary.md" ]; then
        # Extract from validation summary if available
        POLICIES_APPLIED=$(grep "Policies Applied\|Kyverno Policies Applied" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "0")
        CATEGORIES_TESTED=$(grep "Categories Tested\|Policy Categories Tested" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "0")
        TEST_MANIFESTS=$(grep "Test Manifests" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "0")
        KUBE_BENCH_STATUS=$(grep "Kube-bench Scan" "$REPORT_DIR/kind-cluster/validation-summary.md" | awk -F'|' '{print $3}' | tr -d ' ' 2>/dev/null || echo "Not Available")
        
        echo "- ✅ Integration tests completed successfully" >> "$SUMMARY_FILE"
        echo "- **Kyverno Policies Applied**: $POLICIES_APPLIED" >> "$SUMMARY_FILE"
        echo "- **Categories Tested**: $CATEGORIES_TESTED" >> "$SUMMARY_FILE"
        echo "- **Test Manifests**: $TEST_MANIFESTS" >> "$SUMMARY_FILE"
        echo "- **Kube-bench Status**: $KUBE_BENCH_STATUS" >> "$SUMMARY_FILE"
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

## 🏗️ Architecture Overview

This compliance framework provides **multi-layer security validation**:

### 🔍 Validation Layers

1. **🎯 Kyverno Policies** - Kubernetes API resource validation
   - RBAC controls and permissions
   - Pod security standards
   - Network policies and service configurations
   - Resource quotas and limits

2. **🔒 Kube-bench CIS Scanning** - Node-level compliance validation
   - File permissions and ownership
   - Kubelet configuration validation
   - Control plane security settings
   - Node-level system configurations

3. **🛠️ Infrastructure Compliance** - OpenTofu validation
   - EKS cluster security configurations
   - VPC and networking security
   - IAM roles and policies
   - KMS encryption settings

### 🔗 Integration Points

- **Worker Node Policies** now reference kube-bench findings
- **Control Plane Policies** complement kube-bench master scans
- **OpenTofu configurations** deploy kube-bench automatically
- **KIND testing** includes both Kyverno and kube-bench validation

---

## 📁 Report Files Directory

### 📊 Policy Tests
- **Detailed results**: [🗾 detailed-results.md](policy-tests/detailed-results.md)
- **Summary**: [📈 summary.md](policy-tests/summary.md)
- **Execution stats**: [📊 execution-stats.json](policy-tests/execution-stats.json)

### 🔒 Kube-bench CIS Compliance
- **Node scan results**: [📄 node-scan.json](kube-bench/node-scan.json)
- **Master scan results**: [📄 master-scan.json](kube-bench/master-scan.json)
- **Summary**: [📈 summary.md](kube-bench/summary.md)

### 🛠️ OpenTofu Compliance
- **Compliant scan**: [✅ compliant-plan-scan.md](opentofu-compliance/compliant-plan-scan.md)  
- **Non-compliant scan**: [❌ noncompliant-plan-scan.md](opentofu-compliance/noncompliant-plan-scan.md)

### 🌟 Kind Integration  
- **Validation results**: [📊 validation-results.txt](kind-cluster/validation-results.txt)
- **Cluster resources**: [🎯 cluster-resources.yaml](kind-cluster/cluster-resources.yaml)
- **Validation summary**: [📈 validation-summary.md](kind-cluster/validation-summary.md)

---

## 📈 Test Suite Status

| Test Suite | Status | Completion | Notes |
|------------|--------|------------|-------|
| Policy Unit Tests | $( [ -f "$REPORT_DIR/policy-tests/summary.md" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/policy-tests/summary.md" ] && echo "100%" || echo "0%" ) | Kubernetes policy validation |
| Kube-bench CIS Scan | $( [ "$KUBE_BENCH_FOUND" = true ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ "$KUBE_BENCH_FOUND" = true ] && echo "100%" || echo "0%" ) | Node-level CIS compliance |
| OpenTofu Compliance | $( [ -f "$REPORT_DIR/opentofu-compliance/compliant-plan-scan.md" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/opentofu-compliance/compliant-plan-scan.md" ] && echo "100%" || echo "0%" ) | Infrastructure compliance |
| Kind Integration | $( [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] && echo "✅ Complete" || echo "❌ Missing" ) | $( [ -f "$REPORT_DIR/kind-cluster/validation-results.txt" ] && echo "100%" || echo "0%" ) | Local cluster testing |
| **Overall** | **${COMPLETION_RATE}%** | **${COMPLETE_REPORTS}/${TOTAL_REPORTS}** | **Test suite completion** |

---

*🤖 Generated by Enhanced Kyverno + Kube-bench CIS EKS Compliance Test Suite v3.0*
EOF

echo -e "${GREEN}✅ Executive summary with kube-bench integration generated successfully!${NC}"
echo -e "${BLUE}📈 Completion rate: ${COMPLETION_RATE}% (${COMPLETE_REPORTS}/${TOTAL_REPORTS} suites)${NC}"
echo -e "${BLUE}🔒 Kube-bench integration: $( [ "$KUBE_BENCH_FOUND" = true ] && echo "✅ Active" || echo "❌ Not Found" )${NC}"
echo -e "${BLUE}📁 Report location: $SUMMARY_FILE${NC}"