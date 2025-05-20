# Debugging Summary: `kyverno json scan` with Offline Cluster Snapshot

This document summarizes the extensive debugging process undertaken to make `kyverno json scan` work with a full offline snapshot of a Kubernetes cluster's resources.

## Goal

The primary goal was to:
1.  Create a Kind cluster.
2.  Install Kyverno and some sample resources.
3.  Export *all* cluster resources (including Kyverno's own CRDs and resources) into a single JSON file (`reports/resources.json`) structured as a Kubernetes `List`.
4.  Filter this `resources.json` to remove Kyverno-related CRDs and resources, as `kyverno json scan` is not meant to scan these.
5.  Use `kyverno json scan` with the filtered JSON payload and a set of Kyverno policies (from `../kyverno-policies`) to perform an offline scan.

## Initial Problem

The `kyverno json scan` command consistently failed with errors related to parsing the input payload or finding Kyverno's own schemas, even after attempting to filter out Kyverno-specific resources.

## Debugging Steps and Script Evolution

The debugging process involved iterative refinements to two main scripts: `describe_resources.sh` (for creating the cluster snapshot) and `run_kyverno.sh` (for filtering the snapshot and running the scan).

### 1. `describe_resources.sh` (Snapshot Creation)

*   **Initial Approach**: Fetch all known resource types, combine their JSON outputs.
*   **Problem 1: Invalid JSON List Structure**: Early versions struggled with correctly formatting the final `List` object, especially with commas between items.
    *   **Fixes**:
        *   Introduced flags (`FIRST_ITEM_IN_ENTIRE_LIST`) to manage comma placement.
        *   Switched to writing each resource item as a separate JSON object to a temporary JSON Lines file (`.jsonl`).
        *   Used `jq --slurp '.'` on the `.jsonl` file to robustly create the final JSON array for the `items` field in the `List` object. This proved to be the most reliable way to construct the list.
*   **Problem 2: Non-Object Items in the List**: `jq` in `run_kyverno.sh` would complain with `Cannot index string with string "apiVersion"`, indicating that some "items" in the `resources.json` list were strings, not JSON objects. This was a very persistent issue.
    *   **Fixes**:
        *   Added stringent validation within `describe_resources.sh` *before* writing any item to the temporary `.jsonl` file. Each item fetched from `kubectl get ... -o json | jq -c '.items[]'` was individually validated using `jq -e 'type == "object" and (keys_unsorted | length > 0)'` to ensure it was a non-empty JSON object.
        *   Removed an unsafe `xargs` command used for trimming whitespace, which was causing "unterminated quote" errors with complex JSON strings.
        *   Added a final validation step in `describe_resources.sh` to check the assembled `reports/resources.json`:
            1.  `jq -e . "$RESOURCES_JSON"`: Validates overall JSON syntax.
            2.  `jq -e '.items[] | if type == "object" then true else error("Non-object found") end' "$RESOURCES_JSON"`: Explicitly verifies that *every* item in the `.items` array is a JSON object.
    *   **Outcome**: After these changes, `describe_resources.sh` consistently produces a `reports/resources.json` file that passes both these final validation checks.

### 2. `run_kyverno.sh` (Filtering and Scanning)

*   **Initial Approach**: Use `jq` to filter `reports/resources.json` and then pass it to `kyverno json scan`.
*   **Problem 1: `jq` errors on `resources.json`**: As described above, `jq` in this script would fail if `resources.json` contained non-object items. This was resolved by fixing `describe_resources.sh`.
*   **Problem 2: `kyverno json scan` schema error**: Even with a perfectly valid and correctly structured `resources.json` (and subsequently `resources_filtered.json`), `kyverno json scan` consistently failed with:
    `Error: failed to parse document (failed to retrieve validator: failed to locate OpenAPI spec for GV: kyverno.io/v1)`
    *   **Attempted Fixes & Investigations**:
        *   **Refined Filtering**: Ensured the `jq` filter in `run_kyverno.sh` correctly removed `CustomResourceDefinition` kinds and any resources with `apiVersion` ending in `kyverno.io` or `wgpolicyk8s.io`. Debug outputs confirmed the filtering was effective.
        *   **"Sanitization" Step**: Added a step to pipe `resources.json` through `jq '.'` into a new `resources_sanitized.json` file, then re-validated this sanitized file (it also passed all checks) before filtering. This was to rule out any subtle encoding or formatting issues. The error persisted.
        *   **Defensive `jq` Filtering**: Modified the `jq` filter to include `type == "object"` checks *before* attempting to access `.apiVersion` or `.kind` fields, just in case a non-object somehow still made it into the stream for that specific `jq` command. The error persisted.
        *   **Single Policy Test**: Modified `run_kyverno.sh` to first attempt a scan using only the `sample-test-policy.yaml` (a simple `ClusterPolicy`). This *also* failed with the exact same "failed to locate OpenAPI spec" error.

## Current Status and Final Conclusion

*   The `describe_resources.sh` script now robustly creates a `reports/resources.json` file that is a valid Kubernetes `List` where every item in the `.items` array is confirmed to be a JSON object.
*   The `run_kyverno.sh` script correctly processes this file, sanitizes it (for good measure), and filters out unwanted resources, producing a `reports/resources_filtered.json` payload. Debug checks confirm this payload is correctly formed and filtered.

Despite these efforts, `kyverno json scan` continues to fail with:
`Error: failed to parse document (failed to retrieve validator: failed to locate OpenAPI spec for GV: kyverno.io/v1)`

This error occurs even when:
1.  The input payload (`resources_filtered.json`) is demonstrably valid and correctly filtered.
2.  A single, simple, valid Kyverno `ClusterPolicy` (`sample-test-policy.yaml`) is used for the scan.

**The root cause appears to be an inherent behavior or limitation of the `kyverno json scan` command itself:**
The command seems to require access to the OpenAPI schema for the `kyverno.io/v1` group/version (which includes `Policy` and `ClusterPolicy` resources) to validate the policy objects *being used for the scan*. In a fully offline environment, which `json scan` is intended for, it cannot retrieve this schema.

A review of `kyverno json scan --help` shows no flags for providing CRD schemas or OpenAPI specifications offline, unlike other Kyverno subcommands like `kyverno test` (which has `--crds-path`).

**Therefore, the scripts (`describe_resources.sh` and `run_kyverno.sh`) are now functioning correctly in preparing the data. The persistent failure is due to `kyverno json scan`'s apparent need for schema validation of the policy objects themselves, which it cannot satisfy in this offline context without a mechanism to provide those schemas.**

Further resolution would likely require:
*   Changes to the `kyverno json scan` tool to either not require schema validation for policies in this mode, or to provide a flag to load policy CRD schemas offline.
*   Consulting the Kyverno community or documentation for workarounds or clarification on this specific behavior.
*   Considering alternative Kyverno CLI commands like `kyverno test` if the "json scan only" constraint can be relaxed, as `test` is generally more mature for offline manifest scanning and supports offline schema loading.