#!/bin/bash
# Unified script for testing Terraform policies with Kyverno
# Validates both compliant and non-compliant Terraform configurations

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
export KYVERNO_EXPERIMENTAL=true
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPLIANT_DIR="$PROJECT_ROOT/terraform/compliant"
NONCOMPLIANT_DIR="$PROJECT_ROOT/terraform/noncompliant"
POLICY_DIR="$PROJECT_ROOT/policies/terraform"
REPORT_DIR="$PROJECT_ROOT/reports/terraform-compliance"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --compliant-only     Test only compliant configuration"
    echo "  -n, --noncompliant-only  Test only non-compliant configuration"
    echo "  -s, --skip-init          Skip terraform init"
    echo "  -h, --help               Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                       # Test both configurations"
    echo "  $0 --compliant-only      # Test only compliant"
    echo "  $0 --skip-init           # Skip terraform init (use existing plan)"
    exit 0
}

# Parse command line arguments
TEST_COMPLIANT=true
TEST_NONCOMPLIANT=true
SKIP_INIT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--compliant-only)
            TEST_NONCOMPLIANT=false
            shift
            ;;
        -n|--noncompliant-only)
            TEST_COMPLIANT=false
            shift
            ;;
        -s|--skip-init)
            SKIP_INIT=true
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
TOTAL_POLICIES=$(find "$POLICY_DIR" -name "*.yaml" -type f | wc -l | tr -d ' ')

echo -e "${PURPLE}🚀 Terraform Policy Validation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Policy Directory: $POLICY_DIR"
echo -e "Total Policies: $TOTAL_POLICIES"
echo -e "Report Directory: $REPORT_DIR"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Check dependencies
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Error: terraform not found${NC}"
    exit 1
fi

if ! command -v kyverno &> /dev/null; then
    echo -e "${RED}❌ Error: kyverno CLI not found${NC}"
    exit 1
fi

# Function to test a terraform configuration
test_terraform_config() {
    local config_type=$1
    local config_dir=$2
    local report_file="$REPORT_DIR/${config_type}-plan-scan.md"
    
    echo -e "\n${BLUE}📋 Testing $config_type configuration${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Verify directory exists
    if [ ! -d "$config_dir" ]; then
        echo -e "${RED}❌ Error: Directory not found: $config_dir${NC}"
        return 1
    fi
    
    # Initialize Terraform (unless skipped)
    if [[ "$SKIP_INIT" != "true" ]]; then
        echo -e "${YELLOW}⚙️  Initializing Terraform...${NC}"
        terraform -chdir="$config_dir" init -input=false -no-color > /dev/null 2>&1 || {
            echo -e "${RED}❌ Terraform init failed${NC}"
            return 1
        }
    fi
    
    # Generate plan
    echo -e "${YELLOW}⚙️  Generating Terraform plan...${NC}"
    terraform -chdir="$config_dir" plan -out=tfplan.binary -input=false -no-color > /dev/null 2>&1 || {
        echo -e "${RED}❌ Terraform plan failed${NC}"
        return 1
    }
    
    # Convert to JSON
    echo -e "${YELLOW}⚙️  Converting plan to JSON...${NC}"
    terraform -chdir="$config_dir" show -json tfplan.binary > "$config_dir/tfplan.json" 2>&1 || {
        echo -e "${RED}❌ Failed to convert plan to JSON${NC}"
        return 1
    }
    
    # Initialize report
    cat > "$report_file" << EOF
# 📊 Kyverno Terraform Plan Compliance Report - ${config_type^} Configuration

**Generated on**: $(date)
**Total Policies**: $TOTAL_POLICIES

## 🎯 Executive Summary

| Metric | Value |
|--------|-------|
| **Total Policies** | TOTAL_PLACEHOLDER |
| **✅ Successful Scans** | SUCCESS_PLACEHOLDER |
| **❌ Failed Scans** | ERRORS_PLACEHOLDER |
| **Success Rate** | SUCCESS_RATE_PLACEHOLDER |

## 📋 Detailed Test Results

EOF
    
    # Run policy scans
    local policy_count=0
    local scan_errors=0
    local current_policy=0
    
    echo -e "${YELLOW}⚙️  Scanning policies...${NC}"
    
    for policy in "$POLICY_DIR"/*.yaml; do
        if [ -f "$policy" ]; then
            ((policy_count++))
            ((current_policy++))
            
            local progress_percent=$((current_policy * 100 / TOTAL_POLICIES))
            echo -ne "\r${CYAN}Progress: $progress_percent% ($current_policy/$TOTAL_POLICIES)${NC}"
            
            echo "### Policy: \`$(basename "$policy")\` ($current_policy/$TOTAL_POLICIES - $progress_percent%)" >> "$report_file"
            
            # Run scan
            local scan_output
            scan_output=$(kyverno json scan --policy "$policy" --payload "$config_dir/tfplan.json" 2>&1)
            local scan_exit=$?
            
            echo '```' >> "$report_file"
            echo "$scan_output" >> "$report_file"
            echo '```' >> "$report_file"
            echo "" >> "$report_file"
            
            if [ $scan_exit -ne 0 ]; then
                ((scan_errors++))
            fi
        fi
    done
    
    echo # New line after progress
    
    # Update placeholders
    local success_count=$((policy_count - scan_errors))
    local success_rate=$(awk "BEGIN {printf \"%.1f\", $success_count * 100 / $policy_count}")
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i "" "s/TOTAL_PLACEHOLDER/$policy_count/g" "$report_file"
        sed -i "" "s/SUCCESS_PLACEHOLDER/$success_count/g" "$report_file"
        sed -i "" "s/ERRORS_PLACEHOLDER/$scan_errors/g" "$report_file"
        sed -i "" "s/SUCCESS_RATE_PLACEHOLDER/${success_rate}%/g" "$report_file"
    else
        sed -i "s/TOTAL_PLACEHOLDER/$policy_count/g" "$report_file"
        sed -i "s/SUCCESS_PLACEHOLDER/$success_count/g" "$report_file"
        sed -i "s/ERRORS_PLACEHOLDER/$scan_errors/g" "$report_file"
        sed -i "s/SUCCESS_RATE_PLACEHOLDER/${success_rate}%/g" "$report_file"
    fi
    
    # Display summary
    echo -e "${GREEN}✅ Scan completed: $success_count/$policy_count policies passed (${success_rate}%)${NC}"
    echo -e "${BLUE}📊 Results written to: $report_file${NC}"
    
    return 0
}

# Main execution
OVERALL_SUCCESS=true

# Test compliant configuration
if [[ "$TEST_COMPLIANT" == "true" ]]; then
    test_terraform_config "compliant" "$COMPLIANT_DIR" || OVERALL_SUCCESS=false
fi

# Test non-compliant configuration
if [[ "$TEST_NONCOMPLIANT" == "true" ]]; then
    test_terraform_config "noncompliant" "$NONCOMPLIANT_DIR" || OVERALL_SUCCESS=false
fi

# Final summary
echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Overall Summary${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ "$OVERALL_SUCCESS" == "true" ]]; then
    echo -e "${GREEN}✅ All tests completed successfully${NC}"
    
    # Display key findings
    if [[ "$TEST_COMPLIANT" == "true" && -f "$REPORT_DIR/compliant-plan-scan.md" ]]; then
        echo -e "\n${BLUE}Compliant Configuration:${NC}"
        grep -E "PASSED|FAILED" "$REPORT_DIR/compliant-plan-scan.md" 2>/dev/null | head -5 || true
    fi
    
    if [[ "$TEST_NONCOMPLIANT" == "true" && -f "$REPORT_DIR/noncompliant-plan-scan.md" ]]; then
        echo -e "\n${BLUE}Non-compliant Configuration:${NC}"
        grep -E "PASSED|FAILED" "$REPORT_DIR/noncompliant-plan-scan.md" 2>/dev/null | head -5 || true
    fi
    
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi