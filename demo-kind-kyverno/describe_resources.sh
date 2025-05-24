#!/usr/bin/env bash
set -e

# Determine the absolute path of this script's directory
SUB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
OUTPUT_DIR="$SUB_SCRIPT_DIR/reports"
RESOURCES_JSON_TMP="$OUTPUT_DIR/resources_items_tmp.jsonl" # Temporary file for JSON Lines
RESOURCES_JSON="$OUTPUT_DIR/resources.json"

echo "Describing all resources and exporting to JSON List..."

mkdir -p "$OUTPUT_DIR"
> "$RESOURCES_JSON_TMP" # Clear or create temp file

NAMESPACED_RESOURCES=(
  pods services deployments statefulsets daemonsets jobs cronjobs
  configmaps secrets ingresses networkpolicies persistentvolumeclaims
  serviceaccounts roles rolebindings replicasets endpoints events
  limitranges resourcequotas horizontalpodautoscalers leases
)

NON_NAMESPACED_RESOURCES=(
  namespaces nodes clusterroles clusterrolebindings persistentvolumes
  storageclasses customresourcedefinitions apiservices
  mutatingwebhookconfigurations validatingwebhookconfigurations
  certificatesigningrequests runtimeclasses priorityclasses
  podsecuritypolicies volumeattachments csidrivers csinodes ingressclasses controllerrevisions
)

# Function to append resource items as JSON Lines
append_resources_to_tmp() {
  local KUBE_OUTPUT="$1"
  local resource_type_name="$2" # For debugging

  if ! echo "$KUBE_OUTPUT" | jq -e '.items' > /dev/null 2>&1; then
    echo "Warning (append_resources_to_tmp): No '.items' array or invalid JSON from kubectl get $resource_type_name. Output: $KUBE_OUTPUT" >&2
    return
  fi

  local items_processed_count=0
  # Read each line which should be a JSON object from 'kubectl get ... | jq -c .items[]'
  echo "$KUBE_OUTPUT" | jq -c '.items[]' | while IFS= read -r item_json_line || [ -n "$item_json_line" ]; do
    # Ensure the line read is not empty (IFS read might not set -n for last line without newline)
    if [ -z "$item_json_line" ]; then
      continue
    fi

    # Validate that item_json_line is a valid, non-empty JSON object using jq's exit code
    # jq -e will exit 0 if the last output is not false or null.
    # We test if it's an object and has keys.
    if echo "$item_json_line" | jq -e 'type == "object" and (keys_unsorted | length > 0)' > /dev/null; then
      echo "$item_json_line" >> "$RESOURCES_JSON_TMP"
      items_processed_count=$((items_processed_count + 1))
    else
      # This item is not a valid, non-empty JSON object. Log and skip.
      echo "Warning (append_resources_to_tmp): Skipping malformed/empty/non-object JSON item for $resource_type_name. Item was: <<<${item_json_line}>>>" >&2
    fi
  done
}

echo "Exporting all namespaced resources to temporary file..."
for resource_type in "${NAMESPACED_RESOURCES[@]}"; do
  echo "Exporting $resource_type (all namespaces)..."
  KUBE_OUTPUT=$(kubectl get "$resource_type" --all-namespaces -o json 2>/dev/null || echo '{"items":[]}')
  append_resources_to_tmp "$KUBE_OUTPUT" "$resource_type"
done

echo "Exporting all non-namespaced resources to temporary file..."
for resource_type in "${NON_NAMESPACED_RESOURCES[@]}"; do
  echo "Exporting $resource_type..."
  KUBE_OUTPUT=$(kubectl get "$resource_type" -o json 2>/dev/null || echo '{"items":[]}')
  append_resources_to_tmp "$KUBE_OUTPUT" "$resource_type"
done

echo "Constructing final YAML stream from temporary file..."
RESOURCES_YAML_STREAM_FILE="${OUTPUT_DIR}/resources.yaml" # Define the output YAML stream file using OUTPUT_DIR

FIRST_DOC=true
# Read each line (which is a JSON object) from the temporary file
while IFS= read -r json_object; do
    if [ -z "$json_object" ]; then # Skip empty lines if any
        continue
    fi

    if [ "$FIRST_DOC" = true ]; then
        FIRST_DOC=false
    else
        echo "---" # YAML document separator
    fi
    # Convert JSON object to YAML and append to the output file
    echo "$json_object" | yq eval -P -o=yaml '.' -
done < "$RESOURCES_JSON_TMP" > "$RESOURCES_YAML_STREAM_FILE"

rm "$RESOURCES_JSON_TMP" # Remove the temporary JSON stream file

echo "Saved YAML stream of resources to $RESOURCES_YAML_STREAM_FILE"

# Basic validation: Check if the YAML file was created and is not empty
if [ -s "$RESOURCES_YAML_STREAM_FILE" ]; then
    echo "$RESOURCES_YAML_STREAM_FILE created and is not empty. First 10 lines:"
    head -n 10 "$RESOURCES_YAML_STREAM_FILE"
else
    echo "Error: $RESOURCES_YAML_STREAM_FILE is empty or was not created." >&2
    exit 1
fi
