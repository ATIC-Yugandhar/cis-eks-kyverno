#!/usr/bin/env bash
set -e

# Directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Paths
POLICIES_DIR="$SCRIPT_DIR/../kyverno-policies" # Main directory for all policy sets

# !!! IMPORTANT: Please update this placeholder with an ACTUAL policy file path from your policy set !!!
# This policy should be one you expect to apply to the Pod resource (manifests/pod.yaml).
# For example, from a CIS EKS policy set, it might be something like:
# SINGLE_SPECIFIC_POLICY_EXAMPLE="$POLICIES_DIR/eks/eks-restrict-hostpath-volumes.yaml"
# Or if policies are directly under $POLICIES_DIR:
# SINGLE_SPECIFIC_POLICY_EXAMPLE="$POLICIES_DIR/some-pod-policy.yaml"
SINGLE_SPECIFIC_POLICY_EXAMPLE="$POLICIES_DIR/PLACEHOLDER_POLICY_FILENAME.yaml" # USER MUST UPDATE THIS

RESOURCES_DIR="$SCRIPT_DIR/manifests"
POD_RESOURCE_FILE="$RESOURCES_DIR/pod.yaml"
CONFIGMAP_RESOURCE_FILE="$RESOURCES_DIR/configmap.yaml"

APPLY_REPORT_DIR="$SCRIPT_DIR/reports"
SAMPLE_POLICY_APPLY_REPORT_FILE="$APPLY_REPORT_DIR/kyverno_sample_policy_apply_report.txt"
SINGLE_SPECIFIC_POLICY_APPLY_REPORT_FILE="$APPLY_REPORT_DIR/kyverno_single_specific_policy_apply_report.txt"
FULL_POLICIES_APPLY_REPORT_FILE="$APPLY_REPORT_DIR/kyverno_full_policies_apply_report.yaml" # For structured YAML output
FULL_POLICIES_APPLY_REPORT_FILE_STDOUT="$APPLY_REPORT_DIR/kyverno_full_policies_apply_stdout.txt"
FULL_POLICIES_APPLY_REPORT_FILE_STDERR="$APPLY_REPORT_DIR/kyverno_full_policies_apply_stderr.txt"

# Ensure report directory exists
mkdir -p "$APPLY_REPORT_DIR"

# Verify policy files and directories

echo "Running Kyverno tests for all policies in kyverno-policies/"
kyverno test kyverno-policies/
if [ ! -d "$POLICIES_DIR" ]; then echo "Error: Main Policies directory ($POLICIES_DIR) not found."; exit 1; fi

SKIP_SINGLE_SPECIFIC_POLICY_TEST=true
if [[ "$SINGLE_SPECIFIC_POLICY_EXAMPLE" == *PLACEHOLDER* ]]; then
  echo "----------------------------------------------------------------------------------------------------"
  echo "INFO: SINGLE_SPECIFIC_POLICY_EXAMPLE ('$SINGLE_SPECIFIC_POLICY_EXAMPLE') is a placeholder."
  echo "Please update its value in run_kyverno.sh to a specific policy file from '$POLICIES_DIR'"
  echo "if you want to test a single policy from your main set. Skipping this specific test for now."
  echo "----------------------------------------------------------------------------------------------------"
elif [ ! -f "$SINGLE_SPECIFIC_POLICY_EXAMPLE" ]; then
  echo "----------------------------------------------------------------------------------------------------"
  echo "WARNING: SINGLE_SPECIFIC_POLICY_EXAMPLE ('$SINGLE_SPECIFIC_POLICY_EXAMPLE') was not found."
  echo "Please verify the path and filename. Skipping this specific test for now."
  echo "----------------------------------------------------------------------------------------------------"
else
  SKIP_SINGLE_SPECIFIC_POLICY_TEST=false
fi

if [ ! -f "$POD_RESOURCE_FILE" ]; then echo "Error: Pod resource ($POD_RESOURCE_FILE) not found."; exit 1; fi
if [ ! -f "$CONFIGMAP_RESOURCE_FILE" ]; then echo "Error: ConfigMap resource ($CONFIGMAP_RESOURCE_FILE) not found."; exit 1; fi


# Skipped sample policy test invocation as updated to test all policies

if [ "$SKIP_SINGLE_SPECIFIC_POLICY_TEST" = false ]; then
  echo "====================================================================="
  echo "Attempting 'kyverno apply' with SINGLE specific policy ($SINGLE_SPECIFIC_POLICY_EXAMPLE)"
  echo "against Pod resource ($POD_RESOURCE_FILE)..."
  echo "====================================================================="
  # Added -v 2 for verbosity
  KYVERNO_EXPERIMENTAL=true kyverno apply "$SINGLE_SPECIFIC_POLICY_EXAMPLE" -r "$POD_RESOURCE_FILE" --audit-warn -v 2 > "$SINGLE_SPECIFIC_POLICY_APPLY_REPORT_FILE"
  if [ -s "$SINGLE_SPECIFIC_POLICY_APPLY_REPORT_FILE" ]; then
    echo "SUCCESS: Single specific policy apply. Report:"
    cat "$SINGLE_SPECIFIC_POLICY_APPLY_REPORT_FILE"
  else
    echo "WARNING: Single specific policy apply report is empty."
  fi
  echo; echo
fi

echo "====================================================================="
echo "Attempting 'kyverno apply' with FULL policy set from $POLICIES_DIR"
echo "against Pod ($POD_RESOURCE_FILE) and ConfigMap ($CONFIGMAP_RESOURCE_FILE)..."
echo "====================================================================="
RESOURCE_ARGS_FULL_SET=("-r" "$POD_RESOURCE_FILE" "-r" "$CONFIGMAP_RESOURCE_FILE")
echo "Applying full policies to:"
printf "  %s\n" "$POD_RESOURCE_FILE" "$CONFIGMAP_RESOURCE_FILE"

# Temporarily disable 'exit on error' for this command
set +e
# Run kyverno apply, capturing stdout for the report and stderr for error messages
KYVERNO_EXPERIMENTAL=true kyverno apply "$POLICIES_DIR" "${RESOURCE_ARGS_FULL_SET[@]}" \
    --output "$FULL_POLICIES_APPLY_REPORT_FILE" \
    --audit-warn -v=2 \
    > "$FULL_POLICIES_APPLY_REPORT_FILE_STDOUT" 2> "$FULL_POLICIES_APPLY_REPORT_FILE_STDERR"
APPLY_CMD_EXIT_CODE=$?
set -e

# Check stderr specifically for "policy validation error"
if grep -q "policy validation error" "$FULL_POLICIES_APPLY_REPORT_FILE_STDERR"; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERROR: 'kyverno apply' with the full policy set reported a 'policy validation error' in its stderr."
    echo "Exit Code from kyverno apply: $APPLY_CMD_EXIT_CODE"
    echo "Stderr (checked for error, saved to $FULL_POLICIES_APPLY_REPORT_FILE_STDERR):"
    cat "$FULL_POLICIES_APPLY_REPORT_FILE_STDERR"
    echo "Stdout (saved to $FULL_POLICIES_APPLY_REPORT_FILE_STDOUT):"
    cat "$FULL_POLICIES_APPLY_REPORT_FILE_STDOUT"
    echo "Structured Report (saved to $FULL_POLICIES_APPLY_REPORT_FILE):"
    cat "$FULL_POLICIES_APPLY_REPORT_FILE"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    
    echo "Attempting to identify problematic policy by applying one by one..."
    TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT="${APPLY_REPORT_DIR}/temp_individual_policy_apply_stdout.txt" # Renamed from TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT
    TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP="${APPLY_REPORT_DIR}/temp_individual_policy_apply_stderr_loop.txt" # Renamed to avoid conflict
    TEMP_INDIVIDUAL_POLICY_APPLY_REPORT="${APPLY_REPORT_DIR}/temp_individual_policy_apply_report.yaml"
            
    # Loop through each policy file
    find "$POLICIES_DIR" -type f -name "*.yaml" -print0 | while IFS= read -r -d $'\0' policy_file; do
        echo "---------------------------------------------------------------------"
        echo "Attempting to apply single policy: $policy_file"
        
        set +e
        KYVERNO_EXPERIMENTAL=true kyverno apply "$policy_file" "${RESOURCE_ARGS_FULL_SET[@]}" \
            --output "$TEMP_INDIVIDUAL_POLICY_APPLY_REPORT" \
            --audit-warn -v=2 \
            > "$TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT" 2> "$TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP"
        INDIVIDUAL_APPLY_EXIT_CODE=$?
        set -e

        if grep -q "policy validation error" "$TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP"; then
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "ERROR: Problematic policy identified with a validation error: $policy_file"
            echo "Error details from applying this policy individually (stderr, saved to $TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP):"
            cat "$TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP"
            echo "Stdout from individual apply (saved to $TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT):"
            cat "$TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT"
            echo "Report from individual apply (saved to $TEMP_INDIVIDUAL_POLICY_APPLY_REPORT):"
            cat "$TEMP_INDIVIDUAL_POLICY_APPLY_REPORT"
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            # Clean up temporary files from the loop before exiting
            rm -f "$TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT" "$TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP" "$TEMP_INDIVIDUAL_POLICY_APPLY_REPORT"
            exit 1 # Exit immediately, this will stop the script.
        elif [ "$INDIVIDUAL_APPLY_EXIT_CODE" -ne 0 ]; then
            echo "WARNING: Policy $policy_file failed to apply (Exit code: $INDIVIDUAL_APPLY_EXIT_CODE), but not with a 'policy validation error' in its stderr."
            echo "This might be due to enforcement on sample manifests. Stderr (saved to $TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP):"
            cat "$TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP"
            echo "Stdout (saved to $TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT):"
            cat "$TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT"
        else
            echo "SUCCESS: Policy $policy_file applied individually without errors or 'policy validation error' in stderr. Exit code: $INDIVIDUAL_APPLY_EXIT_CODE."
        fi
    done
    # Clean up temporary files from the loop if it completes
    rm -f "$TEMP_INDIVIDUAL_POLICY_APPLY_STDOUT" "$TEMP_INDIVIDUAL_POLICY_APPLY_STDERR_LOOP" "$TEMP_INDIVIDUAL_POLICY_APPLY_REPORT"

    # If the loop finishes, it means the "policy validation error" from the full set was not isolated to a single policy file by this method.
    echo "Individual policy check loop completed."
    echo "The 'policy validation error' detected in the full set apply was not pinpointed to a single policy by the individual checks, or it's a more complex issue."
    echo "Review the initial full apply stderr: $FULL_POLICIES_APPLY_REPORT_FILE_STDERR"
    exit 1 # Exit because a validation error was detected in the full set and not resolved/pinpointed by the loop.
else
    # No "policy validation error" in the stderr of the full apply.
    echo "SUCCESS: Full policy set applied to sample manifests without 'policy validation error' in stderr."
    echo "Exit code from kyverno apply command was: $APPLY_CMD_EXIT_CODE (non-zero is OK if due to enforcement)."
    echo "Stderr from full apply (for info, saved to $FULL_POLICIES_APPLY_REPORT_FILE_STDERR):"
    cat "$FULL_POLICIES_APPLY_REPORT_FILE_STDERR"
    echo "Stdout from full apply (for info, saved to $FULL_POLICIES_APPLY_REPORT_FILE_STDOUT):"
    cat "$FULL_POLICIES_APPLY_REPORT_FILE_STDOUT"
    echo "Structured Report from full apply (for info, saved to $FULL_POLICIES_APPLY_REPORT_FILE):"
    cat "$FULL_POLICIES_APPLY_REPORT_FILE"
    # Policies are considered valid for syntax. Proceed with the rest of the script.
fi

# Main cluster scan based on user request
echo
echo "====================================================================="
echo "Attempting MAIN CLUSTER SCAN of all resources in reports/resources.yaml"
echo "====================================================================="

# Define paths for this scan section
# APPLY_REPORT_DIR is already "$SCRIPT_DIR/reports"
CLUSTER_RESOURCES_YAML="$APPLY_REPORT_DIR/resources.yaml"
KYVERNO_CLUSTER_SCAN_REPORT_YAML="$APPLY_REPORT_DIR/kyverno_scan_cluster_resources_report.yaml"
KYVERNO_SCAN_STDERR_FILE="$APPLY_REPORT_DIR/kyverno_scan_stderr.txt"

# 1. Add Diagnostics Before Main Scan
echo "Verifying content of $CLUSTER_RESOURCES_YAML before scan..."
if [ -s "$CLUSTER_RESOURCES_YAML" ]; then
    echo "$CLUSTER_RESOURCES_YAML is not empty. First 10 lines:"
    head -n 10 "$CLUSTER_RESOURCES_YAML"
else
    echo "ERROR: $CLUSTER_RESOURCES_YAML is empty or does not exist!"
    # Consider adding 'exit 1' if this file is critical for the scan to proceed
fi
echo

echo "Verifying policy directory: $POLICIES_DIR" # POLICIES_DIR is "$SCRIPT_DIR/../kyverno-policies"
ls -l "$POLICIES_DIR/"
echo

# 2. Main Scan Command (modified for better error capture)
echo "Running main Kyverno cluster scan..."
# Using SCRIPT_DIR as it's defined in the script. POLICIES_DIR uses SCRIPT_DIR.
# Using APPLY_REPORT_DIR for report paths.
# Temporarily disable 'exit on error' for the scan command
set +e
KYVERNO_EXPERIMENTAL=true kyverno apply -v=3 "$POLICIES_DIR" --resource "$CLUSTER_RESOURCES_YAML" > "$KYVERNO_CLUSTER_SCAN_REPORT_YAML" 2> "$KYVERNO_SCAN_STDERR_FILE"
SCAN_EXIT_CODE=$?
set -e # Re-enable 'exit on error'

echo "Main cluster scan command finished with exit code: $SCAN_EXIT_CODE"
# We will not exit here even if SCAN_EXIT_CODE is non-zero, as scan failures (policy violations) are expected.
# The purpose is to generate a report.

# Immediately after this command, add:
echo "Stderr from Kyverno main cluster scan (if any, saved to $KYVERNO_SCAN_STDERR_FILE):"
if [ -f "$KYVERNO_SCAN_STDERR_FILE" ]; then
    cat "$KYVERNO_SCAN_STDERR_FILE"
else
    echo "No stderr file found at $KYVERNO_SCAN_STDERR_FILE."
fi
echo

echo "Checking if $KYVERNO_CLUSTER_SCAN_REPORT_YAML was created and is not empty:"
if [ -s "$KYVERNO_CLUSTER_SCAN_REPORT_YAML" ]; then
    echo "$KYVERNO_CLUSTER_SCAN_REPORT_YAML was created and is not empty. First 10 lines:"
    head -n 10 "$KYVERNO_CLUSTER_SCAN_REPORT_YAML" # Show first 10 lines instead of full cat for potentially large reports
else
    echo "WARNING: $KYVERNO_CLUSTER_SCAN_REPORT_YAML is empty or was not created."
    echo "Attempting to run Kyverno apply again with verbose output directly to console for debugging:"
    KYVERNO_EXPERIMENTAL=true kyverno apply -v=4 "$POLICIES_DIR" --resource "$CLUSTER_RESOURCES_YAML"
fi
# End of main cluster scan section
echo
echo "Kyverno apply process finished."
