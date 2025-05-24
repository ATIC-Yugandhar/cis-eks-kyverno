# 🧪 Kyverno Policy Test Results

**Comprehensive test results for all CIS EKS compliance policies**

---

## 📊 Executive Summary

| Metric | Value |
|--------|-------|
| **Total Tests** | TOTAL_PLACEHOLDER |
| **✅ Passed** | PASSED_PLACEHOLDER |
| **❌ Failed** | FAILED_PLACEHOLDER |
| **⚠️ Errors** | ERRORS_PLACEHOLDER |
| **Success Rate** | SUCCESS_RATE_PLACEHOLDER |
| **Total Duration** | DURATION_PLACEHOLDER |

---

## 📋 Detailed Test Results

\n## 🧪 Test: `tests/kubernetes/custom-2.1.1/compliant/kyverno-test.yaml`
**Started:** 02:51:44
**Progress:** 1/54 (1.9%)
\n**Duration:** 0.146s
\n```
Loading test  ( tests/kubernetes/custom-2.1.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────│─────────────────────│──────────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                        [0m │ [40;32mRULE               [0m │ [40;32mRESOURCE                                    [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────│─────────────────────│──────────────────────────────────────────────│────────│────────│
│ 1  │ custom-2-1-1-enable-audit-logs │ check-audit-logging │ v1/ConfigMap/kyverno-aws/compliant-configmap │ Pass   │ Ok     │
│────│────────────────────────────────│─────────────────────│──────────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-2.1.1/noncompliant/kyverno-test.yaml`
**Started:** 02:51:45
**Progress:** 2/54 (3.7%)
\n**Duration:** 0.155s
\n```
Loading test  ( tests/kubernetes/custom-2.1.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────│─────────────────────│─────────────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                        [0m │ [40;32mRULE               [0m │ [40;32mRESOURCE                                       [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────│─────────────────────│─────────────────────────────────────────────────│────────│────────│
│ 1  │ custom-2-1-1-enable-audit-logs │ check-audit-logging │ v1/ConfigMap/kyverno-aws/noncompliant-configmap │ Pass   │ Ok     │
│────│────────────────────────────────│─────────────────────│─────────────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-2.1.2/compliant/kyverno-test.yaml`
**Started:** 02:51:45
**Progress:** 3/54 (5.6%)
\n**Duration:** 0.148s
\n```
Loading test  ( tests/kubernetes/custom-2.1.2/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────────│────────────────────────────│───────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                  [0m │ [40;32mRULE                      [0m │ [40;32mRESOURCE                             [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────────│────────────────────────────│───────────────────────────────────────│────────│────────│
│ 1  │ custom-2-1-2-ensure-audit-logs-collected │ check-audit-log-collection │ v1/ConfigMap/kyverno-aws/compliant-cm │ Pass   │ Ok     │
│────│──────────────────────────────────────────│────────────────────────────│───────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-2.1.2/noncompliant/kyverno-test.yaml`
**Started:** 02:51:45
**Progress:** 4/54 (7.4%)
\n**Duration:** 0.147s
\n```
Loading test  ( tests/kubernetes/custom-2.1.2/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────────│────────────────────────────│──────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                  [0m │ [40;32mRULE                      [0m │ [40;32mRESOURCE                                [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────────│────────────────────────────│──────────────────────────────────────────│────────│────────│
│ 1  │ custom-2-1-2-ensure-audit-logs-collected │ check-audit-log-collection │ v1/ConfigMap/kyverno-aws/noncompliant-cm │ Pass   │ Ok     │
│────│──────────────────────────────────────────│────────────────────────────│──────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.1/compliant/kyverno-test.yaml`
**Started:** 02:51:45
**Progress:** 5/54 (9.3%)
\n**Duration:** 0.146s
\n```
Loading test  ( tests/kubernetes/custom-3.1.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────│──────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                             [0m │ [40;32mRULE                        [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────│──────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-1-kubeconfig-permissions │ check-kubeconfig-permissions │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│─────────────────────────────────────│──────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.1/noncompliant/kyverno-test.yaml`
**Started:** 02:51:46
**Progress:** 6/54 (11.1%)
\n**Duration:** 0.147s
\n```
Loading test  ( tests/kubernetes/custom-3.1.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────│──────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                             [0m │ [40;32mRULE                        [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────│──────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-1-kubeconfig-permissions │ check-kubeconfig-permissions │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│─────────────────────────────────────│──────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.2/compliant/kyverno-test.yaml`
**Started:** 02:51:46
**Progress:** 7/54 (13.0%)
\n**Duration:** 0.147s
\n```
Loading test  ( tests/kubernetes/custom-3.1.2/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────────│────────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                               [0m │ [40;32mRULE                          [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────────────│────────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-2-kubelet-kubeconfig-owner │ check-kubelet-kubeconfig-owner │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│───────────────────────────────────────│────────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.2/noncompliant/kyverno-test.yaml`
**Started:** 02:51:46
**Progress:** 8/54 (14.8%)
\n**Duration:** 1027.929s
\n```
Loading test  ( tests/kubernetes/custom-3.1.2/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────────│────────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                               [0m │ [40;32mRULE                          [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────────────│────────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-2-kubelet-kubeconfig-owner │ check-kubelet-kubeconfig-owner │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│───────────────────────────────────────│────────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.3/compliant/kyverno-test.yaml`
**Started:** 03:08:54
**Progress:** 9/54 (16.7%)
\n**Duration:** 0.148s
\n```
Loading test  ( tests/kubernetes/custom-3.1.3/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────────│──────────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                 [0m │ [40;32mRULE                            [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────────│──────────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-3-kubelet-config-permissions │ check-kubelet-config-permissions │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│─────────────────────────────────────────│──────────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.3/noncompliant/kyverno-test.yaml`
**Started:** 03:08:55
**Progress:** 10/54 (18.5%)
\n**Duration:** 0.147s
\n```
Loading test  ( tests/kubernetes/custom-3.1.3/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────────│──────────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                 [0m │ [40;32mRULE                            [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────────│──────────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-3-kubelet-config-permissions │ check-kubelet-config-permissions │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│─────────────────────────────────────────│──────────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
