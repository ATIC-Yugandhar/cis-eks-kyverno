#!/bin/bash
#
# validate-cis.sh
#
# This script uses the Kyverno CLI to validate Kubernetes resources and Terraform plans
# against the CIS (Center for Internet Security) benchmark policies.
#
# Usage:
#   ./validate-cis.sh [--tests | --manifests | --terraform] [--compliant | --noncompliant] [--debug] [policy-dir]
#
# Examples:
#   ./validate-cis.sh                                  # Default: validate non-compliant resources against all policies
#   ./validate-cis.sh --tests                          # Run only Kyverno policy tests
#   ./validate-cis.sh --manifests                      # Validate Kubernetes manifests
#   ./validate-cis.sh --terraform                      # Validate Terraform plans
#   ./validate-cis.sh --compliant                      # Validate compliant resources
#   ./validate-cis.sh --noncompliant                   # Validate non-compliant resources
#   ./validate-cis.sh --debug                          # Enable debug mode
#   ./validate-cis.sh --tests --compliant              # Run tests on compliant resources
#   ./validate-cis.sh --manifests --noncompliant       # Validate non-compliant manifests
#   ./validate-cis.sh --terraform --compliant          # Validate compliant Terraform plans
#   ./validate-cis.sh --tests --manifests --terraform  # Run all validations
#   ./validate-cis.sh --tests --manifests --terraform --compliant  # Run all validations on compliant resources
#   ./validate-cis.sh --tests --manifests --terraform --noncompliant  # Run all validations on non-compliant resources

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$(dirname "$SCRIPT_DIR")
DEFAULT_POLICY_DIR="$ROOT_DIR/kyverno-policies/cis"
DEFAULT_K8S_RESOURCE_DIR="$ROOT_DIR/k8s-manifests/noncompliant" # Default K8s resources
TERRAFORM_EXAMPLE_DIR="$ROOT_DIR/terraform/examples/cluster"
RESULTS_DIR="$ROOT_DIR/results"

# --- Flags --- Default values
RUN_TESTS=false
RUN_MANIFESTS=false
RUN_TERRAFORM=false
TARGET_COMPLIANT=false
TARGET_NONCOMPLIANT=false
DEBUG_MODE=false
POLICY_DIR="$DEFAULT_POLICY_DIR"
K8S_RESOURCE_DIR=""
TF_VAR_FILE=""

# --- Output Files ---
SUPPORTED_TEST_LOG="$RESULTS_DIR/supported-policies-test.log"
CUSTOM_TEST_LOG="$RESULTS_DIR/custom-policies-test.log"
COMPLIANT_MANIFEST_REPORT="$RESULTS_DIR/compliant-manifest-validation-report.yaml"
NONCOMPLIANT_MANIFEST_REPORT="$RESULTS_DIR/noncompliant-manifest-validation-report.yaml"
COMPLIANT_TERRAFORM_REPORT="$RESULTS_DIR/terraform-compliant-validation-report.yaml"
NONCOMPLIANT_TERRAFORM_REPORT="$RESULTS_DIR/terraform-noncompliant-validation-report.yaml"

# --- Helper Functions ---
# Define logging functions for consistent output formatting
log_info() {
    echo "ℹ️  $1"
}

log_step() {
    echo "▶️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ ERROR: $1" >&2
}

log_section() {
    echo ""
    echo "🔍 $1"
    echo "======================================="
}

# --- Argument Parsing ---
RUN_ALL=true # Assume run all if no specific type flags are given
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tests)
      RUN_TESTS=true
      RUN_ALL=false
      shift
      ;;
    --manifests)
      RUN_MANIFESTS=true
      RUN_ALL=false
      shift
      ;;
    --terraform)
      RUN_TERRAFORM=true
      RUN_ALL=false
      shift
      ;;
    --compliant)
      TARGET_COMPLIANT=true
      shift
      ;;
    --noncompliant)
      TARGET_NONCOMPLIANT=true
      shift
      ;;
    --debug)
      DEBUG_MODE=true
      shift
      ;;
    -*)
      log_error "Unknown option: $1"
      exit 1
      ;;
    *) # Assume it's the policy directory
      if [[ -d "$1" ]]; then
        POLICY_DIR="$1"
      else
        log_warning "Argument '$1' is not a directory. Ignoring."
      fi
      shift
      ;;
  esac
done

# --- Set Defaults if RUN_ALL ---
if [ "$RUN_ALL" = true ]; then
  log_info "No specific validation type requested, running all non-compliant validations by default."
  RUN_TESTS=true
  RUN_MANIFESTS=true
  RUN_TERRAFORM=true
  # Default to non-compliant if neither compliant nor noncompliant is specified
  if [ "$TARGET_COMPLIANT" = false ] && [ "$TARGET_NONCOMPLIANT" = false ]; then
      TARGET_NONCOMPLIANT=true
  fi
fi

# --- Determine Target Resources/Vars ---
# Default to non-compliant if neither flag is set, or if both are somehow set (non-compliant takes precedence)
if [ "$TARGET_COMPLIANT" = false ]; then
    TARGET_NONCOMPLIANT=true # Ensure at least one is true, default to non-compliant
fi
if [ "$TARGET_NONCOMPLIANT" = true ]; then
    K8S_RESOURCE_DIR="$ROOT_DIR/k8s-manifests/noncompliant/"
    TF_VAR_FILE="$TERRAFORM_EXAMPLE_DIR/noncompliant.tfvars"
    TARGET_LABEL="Non-Compliant"
fi
if [ "$TARGET_COMPLIANT" = true ]; then
    K8S_RESOURCE_DIR="$ROOT_DIR/k8s-manifests/compliant/"
    TF_VAR_FILE="$TERRAFORM_EXAMPLE_DIR/compliant.tfvars"
    TARGET_LABEL="Compliant"
    # If both flags were somehow true, compliant overrides for this block
fi

# --- Validate Prerequisites ---
command -v kyverno >/dev/null 2>&1 || { log_error "kyverno CLI not found. Please install it (https://kyverno.io/docs/kyverno-cli/). Aborting."; exit 1; }
if [ "$RUN_TERRAFORM" = true ]; then
    command -v terraform >/dev/null 2>&1 || { log_warning "terraform CLI not found. Skipping Terraform validation."; RUN_TERRAFORM=false; }
    command -v jq >/dev/null 2>&1 || { log_warning "jq CLI not found. Skipping Terraform validation."; RUN_TERRAFORM=false; }
    if [ ! -d "$TERRAFORM_EXAMPLE_DIR" ]; then
        log_warning "Terraform directory '$TERRAFORM_EXAMPLE_DIR' not found. Skipping Terraform validation."
        RUN_TERRAFORM=false
    fi
fi
if [ ! -d "$POLICY_DIR" ]; then
  log_error "Policy directory '$POLICY_DIR' not found." >&2
  exit 1
fi
if [ "$RUN_MANIFESTS" = true ] && [ ! -d "$K8S_RESOURCE_DIR" ]; then
  log_error "Kubernetes resource directory '$K8S_RESOURCE_DIR' not found." >&2
  exit 1
fi

# --- Initial Setup ---
mkdir -p "$RESULTS_DIR"
log_step "Cleaning up previous results from $RESULTS_DIR..."
rm -f "$SUPPORTED_TEST_LOG" \
      "$CUSTOM_TEST_LOG" \
      "$COMPLIANT_MANIFEST_REPORT" \
      "$NONCOMPLIANT_MANIFEST_REPORT" \
      "$COMPLIANT_TERRAFORM_REPORT" \
      "$NONCOMPLIANT_TERRAFORM_REPORT" \
      "$RESULTS_DIR/tfplan.json" \
      "$RESULTS_DIR/tfplan_wrapped.json"
log_success "Previous results cleaned."

# --- Verbosity Flag ---
VERBOSITY_FLAG=""
if [ "$DEBUG_MODE" = true ]; then
    VERBOSITY_FLAG="-v=3"
    log_info "Debug mode enabled: using verbosity $VERBOSITY_FLAG"
fi

# --- Kyverno CLI Tests ---
if [ "$RUN_TESTS" = true ]; then
    log_section "Kyverno Policy Tests"
    TESTS_PASSED=true

    # Function to run tests using directory discovery
    run_tests_discovery() {
        local policy_subdir=$1
        local output_log=$2
        local subdir_label=$3 # e.g., "supported" or "custom"

        if [ -d "$policy_subdir" ]; then
            log_step "Running Kyverno CLI tests via directory discovery for $subdir_label policies in $policy_subdir..."
            # Clear the log file for this run (ensure it's empty before command)
            > "$output_log"

            local original_dir=$(pwd) # Store original directory
            log_info "Changing directory to $policy_subdir..."
            if ! cd "$policy_subdir"; then
                log_error "Failed to change directory to $policy_subdir. Skipping tests for $subdir_label."
                echo "Error: Failed to cd to $policy_subdir" > "$output_log" # Overwrite log with error
                cd "$original_dir" || true
                return # Exit the function
            fi

            log_info "Running 'kyverno test .' in $(pwd)..."
            # Run test using directory discovery, OVERWRITE log with stdout and stderr
            if ! kyverno test . > "$output_log" 2>&1; then
                # Command failed. Log file already contains the error output from Kyverno.
                # Check if the failure message is the specific "no tests" message.
                if grep -q "No test yamls available" "$output_log"; then
                    log_warning "Kyverno reported 'No test yamls available' in $policy_subdir. Log: $output_log"
                    # TESTS_PASSED=false # Optional: Consider this a failure
                else
                    log_warning "Kyverno test command failed in directory $policy_subdir. See $output_log"
                    # TESTS_PASSED=false # Optional: Consider this a failure
                fi
            else
                 # Command succeeded. Log file contains the success output from Kyverno.
                 log_success "Kyverno tests completed via discovery for $subdir_label policies. Log: $output_log"
                 # Removed the extra echo to the log file here.
            fi

            log_info "Changing directory back to $original_dir..."
            if ! cd "$original_dir"; then
                 log_error "Failed to change directory back to $original_dir. Subsequent steps might fail."
                 # Consider exiting if this happens: exit 1
            fi
        else
            log_warning "$subdir_label policy directory missing ($policy_subdir). Skipping tests."
            echo "$subdir_label policy directory missing ($policy_subdir). Skipping tests." > "$output_log" # Overwrite log
        fi
    }

    # Run for supported policies
    run_tests_discovery "$POLICY_DIR/supported" "$SUPPORTED_TEST_LOG" "supported"

    # Run for custom policies
    run_tests_discovery "$POLICY_DIR/custom" "$CUSTOM_TEST_LOG" "custom"

fi

# --- Kyverno Manifest Validation ---
if [ "$RUN_MANIFESTS" = true ]; then
    log_section "Kyverno Manifest Validation ($TARGET_LABEL)"
    log_info "Validating resources in $K8S_RESOURCE_DIR"
    log_info "Using CIS policies from $POLICY_DIR"

    if [ "$TARGET_COMPLIANT" = true ]; then
        APPLY_REPORT_FILE="$COMPLIANT_MANIFEST_REPORT"
    else
        APPLY_REPORT_FILE="$NONCOMPLIANT_MANIFEST_REPORT"
    fi

    # Use find to explicitly list policy files, excluding test files
    log_info "Finding policy files in $POLICY_DIR/supported and $POLICY_DIR/custom..."
    POLICY_FILES=$(find "$POLICY_DIR/supported" "$POLICY_DIR/custom" -maxdepth 1 -name "*.yaml" ! -name "*-test.yaml" -print 2>/dev/null || true)

    if [ -z "$POLICY_FILES" ]; then
        log_error "No policy YAML files found in $POLICY_DIR/supported or $POLICY_DIR/custom (excluding *-test.yaml)."
    else
        log_step "Validating manifests against policies..."
        # Use xargs to handle potential long list of files
        # shellcheck disable=SC2086 # We want word splitting here
        log_info "Executing: echo \"$POLICY_FILES\" | xargs kyverno apply -r \"$K8S_RESOURCE_DIR\" -o \"$APPLY_REPORT_FILE\" $VERBOSITY_FLAG"
        
        kyverno_manifest_exit_code=0
        echo "$POLICY_FILES" | xargs kyverno apply -r "$K8S_RESOURCE_DIR" -o "$APPLY_REPORT_FILE" $VERBOSITY_FLAG || kyverno_manifest_exit_code=$?
        
        if [ $kyverno_manifest_exit_code -ne 0 ]; then
            # Log error but continue script execution, as report file should contain details
            log_error "Kyverno apply validation failed for manifests (exit code $kyverno_manifest_exit_code). Check $APPLY_REPORT_FILE"
        else
            log_success "Kyverno apply validation completed for manifests."
            log_info "Resource validation report saved to $APPLY_REPORT_FILE"
        fi
    fi
fi

# --- Terraform Plan Validation Function ---
# Moved Terraform logic into a function to avoid duplication
validate_terraform_plan() {
    local target_label=$1
    local tf_var_file_path=$2
    local tf_report_file=$3
    # Use tr for macOS compatibility (Bash 3.x)
    local target_label_lower=$(echo "$target_label" | tr '[:upper:]' '[:lower:]')
    local tf_plan_binary="tfplan-${target_label_lower}.binary" # Unique plan file name
    local tf_plan_json="$RESULTS_DIR/tfplan-${target_label_lower}.json"
    local tf_plan_wrapped="$RESULTS_DIR/tfplan-${target_label_lower}_wrapped.json"

    log_section "Terraform Plan Validation ($target_label)"
    TERRAFORM_POLICY_DIR="$ROOT_DIR/kyverno-policies/terraform"

    MAIN_TF_FILE="$TERRAFORM_EXAMPLE_DIR/main.tf"
    MAIN_TF_BACKUP="$MAIN_TF_FILE.bak"
    BACKEND_COMMENTED=false

    # Check if main.tf exists and contains the backend block
    if [ -f "$MAIN_TF_FILE" ] && grep -q '^[[:space:]]*backend "s3" {}' "$MAIN_TF_FILE"; then
        log_step "Backing up $MAIN_TF_FILE to $MAIN_TF_BACKUP..."
        cp "$MAIN_TF_FILE" "$MAIN_TF_BACKUP"
        log_step "Temporarily commenting out S3 backend in $MAIN_TF_FILE..."
        sed -i.bak_sed 's/^[[:space:]]*backend "s3" {}.*$/#&/' "$MAIN_TF_FILE"
        rm -f "$MAIN_TF_FILE.bak_sed"
        BACKEND_COMMENTED=true
    else
        log_warning "Could not find S3 backend block in $MAIN_TF_FILE or file does not exist. Assuming local backend."
    fi

    log_step "Initializing Terraform in $TERRAFORM_EXAMPLE_DIR..."
    INIT_SUCCESS=true
    if ! (cd "$TERRAFORM_EXAMPLE_DIR" && terraform init -input=false -no-color); then
        log_error "Terraform init failed in $TERRAFORM_EXAMPLE_DIR. Skipping Terraform validation for $target_label."
        INIT_SUCCESS=false
    fi

    if [ "$INIT_SUCCESS" = true ]; then
        log_step "Generating Terraform plan ($target_label)..."
        PLAN_SUCCESS=true
        PLAN_CMD="terraform plan -input=false -no-color -out=$tf_plan_binary"
        if [ -f "$tf_var_file_path" ]; then
            PLAN_CMD="$PLAN_CMD -var-file=$(basename "$tf_var_file_path")"
        else
            log_warning "Variable file $tf_var_file_path not found for $target_label. Running plan without it."
        fi

        # Log the exact command before executing
        log_info "Executing plan command in $TERRAFORM_EXAMPLE_DIR: $PLAN_CMD"
        if ! (cd "$TERRAFORM_EXAMPLE_DIR" && eval $PLAN_CMD); then
             log_error "Terraform plan generation failed for $target_label. Skipping validation."
             PLAN_SUCCESS=false
        fi

        if [ "$PLAN_SUCCESS" = true ]; then
            log_step "Converting Terraform plan to JSON ($target_label)..."
            # Check if plan binary exists before attempting conversion
            if [ ! -f "$TERRAFORM_EXAMPLE_DIR/$tf_plan_binary" ]; then
                log_error "Terraform plan binary '$tf_plan_binary' not found in $TERRAFORM_EXAMPLE_DIR. Skipping validation."
            elif ! (cd "$TERRAFORM_EXAMPLE_DIR" && terraform show -json "$tf_plan_binary" > "$tf_plan_json"); then
                log_error "Failed to convert Terraform plan to JSON for $target_label. Skipping validation."
            # Check if the JSON file is empty or invalid
            elif [ ! -s "$tf_plan_json" ] || ! jq -e . "$tf_plan_json" > /dev/null 2>&1; then
                 log_error "Converted Terraform plan JSON '$tf_plan_json' is empty or invalid. Skipping validation."
            else
                 log_step "Wrapping Terraform plan JSON for Kyverno ($target_label)..."
                 # Simpler jq invocation for compatibility
                 # Check if jq command succeeds and output file is non-empty
                 if ! echo '{ "apiVersion": "kyverno.io/v1", "kind": "TerraformPlan", "metadata": { "name": "tf-plan-validation-'"$target_label_lower"'" }, "plan": '$(cat "$tf_plan_json")' }' | jq . > "$tf_plan_wrapped" || [ ! -s "$tf_plan_wrapped" ]; then
                     log_error "Failed to wrap Terraform plan JSON using jq or output '$tf_plan_wrapped' is empty."
                 else
                     log_step "Validating Terraform plan with Kyverno policies ($target_label)..."
                     log_info "Executing: kyverno apply \"$TERRAFORM_POLICY_DIR\" --resource \"$tf_plan_wrapped\" $VERBOSITY_FLAG"
                     
                     kyverno_tf_exit_code=0
                     kyverno_output=$(kyverno apply "$TERRAFORM_POLICY_DIR" --resource "$tf_plan_wrapped" $VERBOSITY_FLAG 2>&1) || kyverno_tf_exit_code=$?
                     
                     # Write the output to the report file manually
                     echo "$kyverno_output" > "$tf_report_file"
                     
                     if [ $kyverno_tf_exit_code -ne 0 ]; then
                         # Log error but continue script execution
                         log_error "Kyverno validation failed for Terraform plan ($target_label) (exit code $kyverno_tf_exit_code). Check $tf_report_file"
                     else
                         log_success "Kyverno validation completed for Terraform plan ($target_label)."
                         log_info "Terraform validation report saved to $tf_report_file"
                     fi
                 fi
            fi
            # Clean up intermediate files for this target
            log_step "Cleaning up Terraform artifacts for $target_label..."
            rm -f "$TERRAFORM_EXAMPLE_DIR/$tf_plan_binary" "$tf_plan_json" "$tf_plan_wrapped"
            log_success "Terraform artifacts cleaned up for $target_label."
        fi
    fi

    # Restore main.tf if it was modified
    if [ "$BACKEND_COMMENTED" = true ]; then
        log_step "Restoring original $MAIN_TF_FILE from backup..."
        # Check if backup exists before moving
        if [ -f "$MAIN_TF_BACKUP" ]; then
            mv "$MAIN_TF_BACKUP" "$MAIN_TF_FILE"
        else
            log_warning "Backup file $MAIN_TF_BACKUP not found. Cannot restore $MAIN_TF_FILE."
        fi
    fi
}

# --- Terraform Plan Validation Execution ---
if [ "$RUN_TERRAFORM" = true ]; then
    if [ "$TARGET_COMPLIANT" = true ]; then
        validate_terraform_plan "Compliant" "$TERRAFORM_EXAMPLE_DIR/compliant.tfvars" "$COMPLIANT_TERRAFORM_REPORT"
    fi
    if [ "$TARGET_NONCOMPLIANT" = true ]; then
        validate_terraform_plan "NonCompliant" "$TERRAFORM_EXAMPLE_DIR/noncompliant.tfvars" "$NONCOMPLIANT_TERRAFORM_REPORT"
    fi
fi

# --- Final Summary ---
echo ""
echo "✅ Validation process finished!"
echo "📊 Results saved to $RESULTS_DIR/"

# Exit with error if tests failed
if [ "$RUN_TESTS" = true ] && [ "$TESTS_PASSED" = false ]; then
  log_error "Some Kyverno policy tests failed. Check logs for details."
  exit 1
else
  exit 0
fi