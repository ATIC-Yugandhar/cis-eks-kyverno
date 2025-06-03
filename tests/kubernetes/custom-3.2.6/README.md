# custom-3.2.6 Test Notes

## Why This Test May Not Work as Expected

Kyverno CLI does not reliably enforce pattern-based validation for string fields in Node annotations. As a result, the test runner may not evaluate these rules, and no tests are reported as passed or failed. This is a known limitation of Kyverno CLI for this type of check.

## Test Cases
- `compliant/node.yaml` + `kyverno-test.yaml`: Should pass (makeIPTablesUtilChains is true)
- `noncompliant/node.yaml` + `kyverno-test.yaml`: Should fail (makeIPTablesUtilChains is false)

**Total test cases:** 2

**Status:** No tests reported due to CLI limitation. 