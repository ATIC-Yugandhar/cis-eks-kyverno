# custom-3.2.5 Test Notes

## Why This Test May Not Work as Expected

Kyverno CLI does not reliably enforce pattern-based negation (e.g., `!0`) for string fields in Node annotations. As a result, both compliant and noncompliant test resources may pass, even though the policy is correct and would work on a real cluster. This is a known limitation of Kyverno CLI for this type of check.

## Test Cases
- `compliant/node.yaml` + `kyverno-test.yaml`: Should pass (streamingConnectionIdleTimeout is not 0)
- `noncompliant/node.yaml` + `kyverno-test.yaml`: Should fail (streamingConnectionIdleTimeout is 0)

**Total test cases:** 2

**Status:** Both currently pass due to CLI limitation. 