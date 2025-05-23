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
**Started:** 16:03:41
**Progress:** 1/54 (1.8%)
\n**Duration:** .140891000s
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
**Started:** 16:03:41
**Progress:** 2/54 (3.7%)
\n**Duration:** .141542000s
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
**Started:** 16:03:41
**Progress:** 3/54 (5.5%)
\n**Duration:** .143295000s
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
**Started:** 16:03:42
**Progress:** 4/54 (7.4%)
\n**Duration:** .145151000s
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
**Started:** 16:03:42
**Progress:** 5/54 (9.2%)
\n**Duration:** .144316000s
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
**Started:** 16:03:42
**Progress:** 6/54 (11.1%)
\n**Duration:** .144471000s
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
**Started:** 16:03:42
**Progress:** 7/54 (12.9%)
\n**Duration:** .146249000s
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
**Started:** 16:03:43
**Progress:** 8/54 (14.8%)
\n**Duration:** .146011000s
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
**Started:** 16:03:43
**Progress:** 9/54 (16.6%)
\n**Duration:** .145054000s
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
**Started:** 16:03:43
**Progress:** 10/54 (18.5%)
\n**Duration:** .142810000s
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
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.4/compliant/kyverno-test.yaml`
**Started:** 16:03:44
**Progress:** 11/54 (20.3%)
\n**Duration:** .142731000s
\n```
Loading test  ( tests/kubernetes/custom-3.1.4/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────│────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                           [0m │ [40;32mRULE                      [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────────│────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-4-kubelet-config-owner │ check-kubelet-config-owner │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│───────────────────────────────────│────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.1.4/noncompliant/kyverno-test.yaml`
**Started:** 16:03:44
**Progress:** 12/54 (22.2%)
\n**Duration:** .143941000s
\n```
Loading test  ( tests/kubernetes/custom-3.1.4/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────│────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                           [0m │ [40;32mRULE                      [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────────│────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-1-4-kubelet-config-owner │ check-kubelet-config-owner │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│───────────────────────────────────│────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.1/compliant/kyverno-test.yaml`
**Started:** 16:03:44
**Progress:** 13/54 (24.0%)
\n**Duration:** .242030000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 2 policies to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────────────│─────────────────────────────────│──────────────────────────────────────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                      [0m │ [40;32mRULE                           [0m │ [40;32mRESOURCE                                                                [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────────────│─────────────────────────────────│──────────────────────────────────────────────────────────────────────────│────────│────────│
│ 1  │ cis-3-2-1-anonymous-auth-not-enabled         │ disallow-anonymous-role-binding │ rbac.authorization.k8s.io/v1/RoleBinding/secure-ns/compliant-rolebinding │ Pass   │ Ok     │
│ 2  │ cis-3-2-2-authorization-mode-not-alwaysallow │ disallow-cluster-admin-binding  │ rbac.authorization.k8s.io/v1/RoleBinding/secure-ns/compliant-rolebinding │ Pass   │ Ok     │
│────│──────────────────────────────────────────────│─────────────────────────────────│──────────────────────────────────────────────────────────────────────────│────────│────────│


Test Summary: 2 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:44
**Progress:** 14/54 (25.9%)
\n**Duration:** .236313000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 2 policies to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────────────│─────────────────────────────────│─────────────────────────────────────────────────────────────────────────────│────────│─────────────────────│
│ [40;32mID[0m │ [40;32mPOLICY                                      [0m │ [40;32mRULE                           [0m │ [40;32mRESOURCE                                                                   [0m │ [40;32mRESULT[0m │ [40;32mREASON             [0m │
│────│──────────────────────────────────────────────│─────────────────────────────────│─────────────────────────────────────────────────────────────────────────────│────────│─────────────────────│
│ 1  │ cis-3-2-1-anonymous-auth-not-enabled         │ disallow-anonymous-role-binding │ rbac.authorization.k8s.io/v1/RoleBinding/secure-ns/noncompliant-rolebinding │ Pass   │ Ok                  │
│ 2  │ cis-3-2-2-authorization-mode-not-alwaysallow │ disallow-cluster-admin-binding  │ rbac.authorization.k8s.io/v1/RoleBinding/secure-ns/noncompliant-rolebinding │ Pass   │ Want fail, got pass │
│────│──────────────────────────────────────────────│─────────────────────────────────│─────────────────────────────────────────────────────────────────────────────│────────│─────────────────────│


Test Summary: 2 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.3/compliant/kyverno-test.yaml`
**Started:** 16:03:45
**Progress:** 15/54 (27.7%)
\n**Duration:** .143689000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.3/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────│──────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                     [0m │ [40;32mRULE                [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────│──────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-3-client-ca-file │ check-client-ca-file │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│─────────────────────────────│──────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.3/noncompliant/kyverno-test.yaml`
**Started:** 16:03:45
**Progress:** 16/54 (29.6%)
\n**Duration:** .143387000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.3/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────│──────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                     [0m │ [40;32mRULE                [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────│──────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-3-client-ca-file │ check-client-ca-file │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│─────────────────────────────│──────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.4/compliant/kyverno-test.yaml`
**Started:** 16:03:45
**Progress:** 17/54 (31.4%)
\n**Duration:** .143105000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.4/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────│──────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                     [0m │ [40;32mRULE                [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────│──────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-4-read-only-port │ check-read-only-port │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│─────────────────────────────│──────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.4/noncompliant/kyverno-test.yaml`
**Started:** 16:03:46
**Progress:** 18/54 (33.3%)
\n**Duration:** .144159000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.4/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────│──────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                     [0m │ [40;32mRULE                [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────│──────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-4-read-only-port │ check-read-only-port │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│─────────────────────────────│──────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.5/compliant/kyverno-test.yaml`
**Started:** 16:03:46
**Progress:** 19/54 (35.1%)
\n**Duration:** .144254000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.5/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────────────│─────────────────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                        [0m │ [40;32mRULE                                   [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-5-streaming-connection-idle-timeout │ check-streaming-connection-idle-timeout │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.5/noncompliant/kyverno-test.yaml`
**Started:** 16:03:46
**Progress:** 20/54 (37.0%)
\n**Duration:** .141027000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.5/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────────────│─────────────────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                        [0m │ [40;32mRULE                                   [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-5-streaming-connection-idle-timeout │ check-streaming-connection-idle-timeout │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.6/compliant/kyverno-test.yaml`
**Started:** 16:03:46
**Progress:** 21/54 (38.8%)
\n**Duration:** .143269000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.6/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────│─────────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                [0m │ [40;32mRULE                           [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────│─────────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-6-make-iptables-util-chains │ check-make-iptables-util-chains │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│────────────────────────────────────────│─────────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.6/noncompliant/kyverno-test.yaml`
**Started:** 16:03:47
**Progress:** 22/54 (40.7%)
\n**Duration:** .143926000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.6/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────│─────────────────────────────────│───────────────────────────────────│────────│─────────────────────│
│ [40;32mID[0m │ [40;32mPOLICY                                [0m │ [40;32mRULE                           [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON             [0m │
│────│────────────────────────────────────────│─────────────────────────────────│───────────────────────────────────│────────│─────────────────────│
│ 1  │ custom-3-2-6-make-iptables-util-chains │ check-make-iptables-util-chains │ v1/Node/default/noncompliant-node │ Fail   │ Want pass, got fail │
│────│────────────────────────────────────────│─────────────────────────────────│───────────────────────────────────│────────│─────────────────────│


Test Summary: 0 tests passed and 1 tests failed

Error: 1 tests failed
```
\n❌ **ERROR**: Test command failed with exit code 1
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.7/compliant/kyverno-test.yaml`
**Started:** 16:03:47
**Progress:** 23/54 (42.5%)
\n**Duration:** .144674000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.7/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────│────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                       [0m │ [40;32mRULE                  [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────│────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-7-event-record-qps │ check-event-record-qps │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│───────────────────────────────│────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.7/noncompliant/kyverno-test.yaml`
**Started:** 16:03:47
**Progress:** 24/54 (44.4%)
\n**Duration:** .144525000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.7/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────│────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                       [0m │ [40;32mRULE                  [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────│────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-7-event-record-qps │ check-event-record-qps │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│───────────────────────────────│────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.8/compliant/kyverno-test.yaml`
**Started:** 16:03:48
**Progress:** 25/54 (46.2%)
\n**Duration:** .142007000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.8/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────│───────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                          [0m │ [40;32mRULE                     [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────│───────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-8-rotate-certificates │ check-rotate-certificates │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│──────────────────────────────────│───────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.8/noncompliant/kyverno-test.yaml`
**Started:** 16:03:48
**Progress:** 26/54 (48.1%)
\n**Duration:** .143153000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.8/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────│───────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                          [0m │ [40;32mRULE                     [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────│───────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-8-rotate-certificates │ check-rotate-certificates │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│──────────────────────────────────│───────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.9/compliant/kyverno-test.yaml`
**Started:** 16:03:48
**Progress:** 27/54 (50.0%)
\n**Duration:** .146955000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.9/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────────────│─────────────────────────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                        [0m │ [40;32mRULE                                   [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-9-rotate-kubelet-server-certificate │ check-rotate-kubelet-server-certificate │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-3.2.9/noncompliant/kyverno-test.yaml`
**Started:** 16:03:48
**Progress:** 28/54 (51.8%)
\n**Duration:** .144880000s
\n```
Loading test  ( tests/kubernetes/custom-3.2.9/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────────────│─────────────────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                        [0m │ [40;32mRULE                                   [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-3-2-9-rotate-kubelet-server-certificate │ check-rotate-kubelet-server-certificate │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│────────────────────────────────────────────────│─────────────────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.1.7/compliant/kyverno-test.yaml`
**Started:** 16:03:49
**Progress:** 29/54 (53.7%)
\n**Duration:** .135613000s
\n```
Loading test  ( tests/kubernetes/custom-4.1.7/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────│──────────────────────────────│────────────────────────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                             [0m │ [40;32mRULE                        [0m │ [40;32mRESOURCE                                                  [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────│──────────────────────────────│────────────────────────────────────────────────────────────│────────│────────│
│ 1  │ custom-4-1-7-cluster-access-manager │ check-cluster-access-manager │ rbac.authorization.k8s.io/v1/Role/secure-ns/compliant-role │ Pass   │ Ok     │
│────│─────────────────────────────────────│──────────────────────────────│────────────────────────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.1.7/noncompliant/kyverno-test.yaml`
**Started:** 16:03:49
**Progress:** 30/54 (55.5%)
\n**Duration:** .144197000s
\n```
Loading test  ( tests/kubernetes/custom-4.1.7/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────│──────────────────────────────│───────────────────────────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                             [0m │ [40;32mRULE                        [0m │ [40;32mRESOURCE                                                     [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────│──────────────────────────────│───────────────────────────────────────────────────────────────│────────│────────│
│ 1  │ custom-4-1-7-cluster-access-manager │ check-cluster-access-manager │ rbac.authorization.k8s.io/v1/Role/secure-ns/noncompliant-role │ Pass   │ Ok     │
│────│─────────────────────────────────────│──────────────────────────────│───────────────────────────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.1.8/compliant/kyverno-test.yaml`
**Started:** 16:03:49
**Progress:** 31/54 (57.4%)
\n**Duration:** .147387000s
\n```
Loading test  ( tests/kubernetes/custom-4.1.8/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────────────│──────────────────────────│────────────────────────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                   [0m │ [40;32mRULE                    [0m │ [40;32mRESOURCE                                                  [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────────────────│──────────────────────────│────────────────────────────────────────────────────────────│────────│────────│
│ 1  │ cis-4-1-8-limit-bind-impersonate-escalate │ restrict-sensitive-verbs │ rbac.authorization.k8s.io/v1/Role/secure-ns/compliant-role │ Pass   │ Ok     │
│────│───────────────────────────────────────────│──────────────────────────│────────────────────────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.1.8/noncompliant/kyverno-test.yaml`
**Started:** 16:03:49
**Progress:** 32/54 (59.2%)
\n**Duration:** .145483000s
\n```
Loading test  ( tests/kubernetes/custom-4.1.8/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────────────│──────────────────────────│───────────────────────────────────────────────────────────────│────────│─────────────────────│
│ [40;32mID[0m │ [40;32mPOLICY                                   [0m │ [40;32mRULE                    [0m │ [40;32mRESOURCE                                                     [0m │ [40;32mRESULT[0m │ [40;32mREASON             [0m │
│────│───────────────────────────────────────────│──────────────────────────│───────────────────────────────────────────────────────────────│────────│─────────────────────│
│ 1  │ cis-4-1-8-limit-bind-impersonate-escalate │ restrict-sensitive-verbs │ rbac.authorization.k8s.io/v1/Role/secure-ns/noncompliant-role │ Pass   │ Want fail, got pass │
│────│───────────────────────────────────────────│──────────────────────────│───────────────────────────────────────────────────────────────│────────│─────────────────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.3.1/compliant/kyverno-test.yaml`
**Started:** 16:03:50
**Progress:** 33/54 (61.1%)
\n**Duration:** .145900000s
\n```
Loading test  ( tests/kubernetes/custom-4.3.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────────│─────────────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                    [0m │ [40;32mRULE                               [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────────│─────────────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-4-3-1-cni-supports-network-policies │ check-cni-supports-network-policies │ v1/Namespace/default/compliant-ns │ Pass   │ Ok     │
│────│────────────────────────────────────────────│─────────────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.3.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:50
**Progress:** 34/54 (62.9%)
\n**Duration:** .143920000s
\n```
Loading test  ( tests/kubernetes/custom-4.3.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────────────────│─────────────────────────────────────│──────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                    [0m │ [40;32mRULE                               [0m │ [40;32mRESOURCE                            [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────────────────│─────────────────────────────────────│──────────────────────────────────────│────────│────────│
│ 1  │ custom-4-3-1-cni-supports-network-policies │ check-cni-supports-network-policies │ v1/Namespace/default/noncompliant-ns │ Pass   │ Ok     │
│────│────────────────────────────────────────────│─────────────────────────────────────│──────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.4.2/compliant/kyverno-test.yaml`
**Started:** 16:03:50
**Progress:** 35/54 (64.8%)
\n**Duration:** .142988000s
\n```
Loading test  ( tests/kubernetes/custom-4.4.2/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────│───────────────────────────────│────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                              [0m │ [40;32mRULE                         [0m │ [40;32mRESOURCE                          [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────│───────────────────────────────│────────────────────────────────────│────────│────────│
│ 1  │ custom-4-4-2-external-secret-storage │ check-external-secret-storage │ v1/Secret/default/compliant-secret │ Pass   │ Ok     │
│────│──────────────────────────────────────│───────────────────────────────│────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.4.2/noncompliant/kyverno-test.yaml`
**Started:** 16:03:50
**Progress:** 36/54 (66.6%)
\n**Duration:** .143131000s
\n```
Loading test  ( tests/kubernetes/custom-4.4.2/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────│───────────────────────────────│───────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                              [0m │ [40;32mRULE                         [0m │ [40;32mRESOURCE                             [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────│───────────────────────────────│───────────────────────────────────────│────────│────────│
│ 1  │ custom-4-4-2-external-secret-storage │ check-external-secret-storage │ v1/Secret/default/noncompliant-secret │ Pass   │ Ok     │
│────│──────────────────────────────────────│───────────────────────────────│───────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.5.1/compliant/kyverno-test.yaml`
**Started:** 16:03:51
**Progress:** 37/54 (68.5%)
\n**Duration:** .143241000s
\n```
Loading test  ( tests/kubernetes/custom-4.5.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────────│────────────────────────────│────────────│────────│──────────│
│ [40;32mID[0m │ [40;32mPOLICY                                 [0m │ [40;32mRULE                      [0m │ [40;32mRESOURCE  [0m │ [40;32mRESULT[0m │ [40;32mREASON  [0m │
│────│─────────────────────────────────────────│────────────────────────────│────────────│────────│──────────│
│ 1  │ cis-4-5-1-use-namespaces-for-boundaries │ disallow-default-namespace │ v1/Pod/Pod │ Pass   │ Excluded │
│────│─────────────────────────────────────────│────────────────────────────│────────────│────────│──────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-4.5.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:51
**Progress:** 38/54 (70.3%)
\n**Duration:** .143944000s
\n```
Loading test  ( tests/kubernetes/custom-4.5.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────────│────────────────────────────│─────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                 [0m │ [40;32mRULE                      [0m │ [40;32mRESOURCE                       [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────────│────────────────────────────│─────────────────────────────────│────────│────────│
│ 1  │ cis-4-5-1-use-namespaces-for-boundaries │ disallow-default-namespace │ v1/Pod/default/noncompliant-pod │ Pass   │ Ok     │
│────│─────────────────────────────────────────│────────────────────────────│─────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.1.1/compliant/kyverno-test.yaml`
**Started:** 16:03:51
**Progress:** 39/54 (72.2%)
\n**Duration:** .143513000s
\n```
Loading test  ( tests/kubernetes/custom-5.1.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────│──────────────────────│──────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                     [0m │ [40;32mRULE                [0m │ [40;32mRESOURCE                    [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────│──────────────────────│──────────────────────────────│────────│────────│
│ 1  │ custom-5-1-1-image-scanning │ check-image-scanning │ v1/Pod/default/compliant-pod │ Pass   │ Ok     │
│────│─────────────────────────────│──────────────────────│──────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.1.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:52
**Progress:** 40/54 (74.0%)
\n**Duration:** .142914000s
\n```
Loading test  ( tests/kubernetes/custom-5.1.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────│──────────────────────│─────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                     [0m │ [40;32mRULE                [0m │ [40;32mRESOURCE                       [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────│──────────────────────│─────────────────────────────────│────────│────────│
│ 1  │ custom-5-1-1-image-scanning │ check-image-scanning │ v1/Pod/default/noncompliant-pod │ Pass   │ Ok     │
│────│─────────────────────────────│──────────────────────│─────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.1.2/compliant/kyverno-test.yaml`
**Started:** 16:03:52
**Progress:** 41/54 (75.9%)
\n**Duration:** .235903000s
\n```
Loading test  ( tests/kubernetes/custom-5.1.2/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 2 policies to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────────│──────────────────────────────────│────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                 [0m │ [40;32mRULE                            [0m │ [40;32mRESOURCE                              [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────────│──────────────────────────────────│────────────────────────────────────────│────────│────────│
│ 1  │ custom-5-1-2-minimize-ecr-access        │ check-minimize-ecr-access        │ v1/ServiceAccount/default/compliant-sa │ Pass   │ Ok     │
│ 2  │ custom-5-1-3-limit-ecr-access-read-only │ check-limit-ecr-access-read-only │ v1/ServiceAccount/default/compliant-sa │ Pass   │ Ok     │
│────│─────────────────────────────────────────│──────────────────────────────────│────────────────────────────────────────│────────│────────│


Test Summary: 2 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.1.2/noncompliant/kyverno-test.yaml`
**Started:** 16:03:52
**Progress:** 42/54 (77.7%)
\n**Duration:** .242201000s
\n```
Loading test  ( tests/kubernetes/custom-5.1.2/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 2 policies to 1 resource with 0 exceptions ...
  Checking results ...

│────│─────────────────────────────────────────│──────────────────────────────────│───────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                 [0m │ [40;32mRULE                            [0m │ [40;32mRESOURCE                                 [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│─────────────────────────────────────────│──────────────────────────────────│───────────────────────────────────────────│────────│────────│
│ 1  │ custom-5-1-2-minimize-ecr-access        │ check-minimize-ecr-access        │ v1/ServiceAccount/default/noncompliant-sa │ Pass   │ Ok     │
│ 2  │ custom-5-1-3-limit-ecr-access-read-only │ check-limit-ecr-access-read-only │ v1/ServiceAccount/default/noncompliant-sa │ Pass   │ Ok     │
│────│─────────────────────────────────────────│──────────────────────────────────│───────────────────────────────────────────│────────│────────│


Test Summary: 2 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.3.1/compliant/kyverno-test.yaml`
**Started:** 16:03:53
**Progress:** 43/54 (79.6%)
\n**Duration:** .146228000s
\n```
Loading test  ( tests/kubernetes/custom-5.3.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────────────────│───────────────────────────────────│───────────────────────────────────────────────────│────────│──────────│
│ [40;32mID[0m │ [40;32mPOLICY                                       [0m │ [40;32mRULE                             [0m │ [40;32mRESOURCE                                         [0m │ [40;32mRESULT[0m │ [40;32mREASON  [0m │
│────│───────────────────────────────────────────────│───────────────────────────────────│───────────────────────────────────────────────────│────────│──────────│
│ 1  │ cis-5.3.1-kms-secret-encryption-comprehensive │ validate-terraform-eks-encryption │ json.kyverno.io/json.kyverno.io/v1alpha1/v1alpha1 │ Pass   │ Excluded │
│ 2  │ cis-5.3.1-kms-secret-encryption-comprehensive │ validate-kms-key-policy           │ json.kyverno.io/json.kyverno.io/v1alpha1/v1alpha1 │ Pass   │ Excluded │
│────│───────────────────────────────────────────────│───────────────────────────────────│───────────────────────────────────────────────────│────────│──────────│


Test Summary: 2 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.3.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:53
**Progress:** 44/54 (81.4%)
\n**Duration:** .143259000s
\n```
Loading test  ( tests/kubernetes/custom-5.3.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────────────────────│───────────────────────────────────│───────────────────────────────────────────────────│────────│──────────│
│ [40;32mID[0m │ [40;32mPOLICY                                       [0m │ [40;32mRULE                             [0m │ [40;32mRESOURCE                                         [0m │ [40;32mRESULT[0m │ [40;32mREASON  [0m │
│────│───────────────────────────────────────────────│───────────────────────────────────│───────────────────────────────────────────────────│────────│──────────│
│ 1  │ cis-5.3.1-kms-secret-encryption-comprehensive │ validate-terraform-eks-encryption │ json.kyverno.io/json.kyverno.io/v1alpha1/v1alpha1 │ Pass   │ Excluded │
│ 2  │ cis-5.3.1-kms-secret-encryption-comprehensive │ validate-kms-key-policy           │ json.kyverno.io/json.kyverno.io/v1alpha1/v1alpha1 │ Pass   │ Excluded │
│────│───────────────────────────────────────────────│───────────────────────────────────│───────────────────────────────────────────────────│────────│──────────│


Test Summary: 2 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.1/compliant/kyverno-test.yaml`
**Started:** 16:03:53
**Progress:** 45/54 (83.3%)
\n**Duration:** .143249000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────────────│───────────────────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                      [0m │ [40;32mRULE                                 [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────────────│───────────────────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-1-restrict-control-plane-endpoint │ check-restrict-control-plane-endpoint │ v1/Namespace/default/compliant-ns │ Pass   │ Ok     │
│────│──────────────────────────────────────────────│───────────────────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:53
**Progress:** 46/54 (85.1%)
\n**Duration:** .143217000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│──────────────────────────────────────────────│───────────────────────────────────────│──────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                                      [0m │ [40;32mRULE                                 [0m │ [40;32mRESOURCE                            [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│──────────────────────────────────────────────│───────────────────────────────────────│──────────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-1-restrict-control-plane-endpoint │ check-restrict-control-plane-endpoint │ v1/Namespace/default/noncompliant-ns │ Pass   │ Ok     │
│────│──────────────────────────────────────────────│───────────────────────────────────────│──────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.2/compliant/kyverno-test.yaml`
**Started:** 16:03:54
**Progress:** 47/54 (87.0%)
\n**Duration:** .139545000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.2/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────│────────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                       [0m │ [40;32mRULE                  [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────│────────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-2-private-endpoint │ check-private-endpoint │ v1/ConfigMap/default/compliant-cm │ Pass   │ Ok     │
│────│───────────────────────────────│────────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.2/noncompliant/kyverno-test.yaml`
**Started:** 16:03:54
**Progress:** 48/54 (88.8%)
\n**Duration:** .143771000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.2/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│───────────────────────────────│────────────────────────│──────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                       [0m │ [40;32mRULE                  [0m │ [40;32mRESOURCE                            [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│───────────────────────────────│────────────────────────│──────────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-2-private-endpoint │ check-private-endpoint │ v1/ConfigMap/default/noncompliant-cm │ Pass   │ Ok     │
│────│───────────────────────────────│────────────────────────│──────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.3/compliant/kyverno-test.yaml`
**Started:** 16:03:54
**Progress:** 49/54 (90.7%)
\n**Duration:** .146520000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.3/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────│─────────────────────│────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                    [0m │ [40;32mRULE               [0m │ [40;32mRESOURCE                      [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────│─────────────────────│────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-3-private-nodes │ check-private-nodes │ v1/Node/default/compliant-node │ Pass   │ Ok     │
│────│────────────────────────────│─────────────────────│────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.3/noncompliant/kyverno-test.yaml`
**Started:** 16:03:54
**Progress:** 50/54 (92.5%)
\n**Duration:** .146151000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.3/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────│─────────────────────│───────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                    [0m │ [40;32mRULE               [0m │ [40;32mRESOURCE                         [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────│─────────────────────│───────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-3-private-nodes │ check-private-nodes │ v1/Node/default/noncompliant-node │ Pass   │ Ok     │
│────│────────────────────────────│─────────────────────│───────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.5/compliant/kyverno-test.yaml`
**Started:** 16:03:55
**Progress:** 51/54 (94.4%)
\n**Duration:** .144244000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.5/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────│─────────────────────────│──────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                        [0m │ [40;32mRULE                   [0m │ [40;32mRESOURCE                        [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────│─────────────────────────│──────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-5-tls-load-balancer │ check-tls-load-balancer │ v1/Service/default/compliant-svc │ Pass   │ Ok     │
│────│────────────────────────────────│─────────────────────────│──────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.4.5/noncompliant/kyverno-test.yaml`
**Started:** 16:03:55
**Progress:** 52/54 (96.2%)
\n**Duration:** .143615000s
\n```
Loading test  ( tests/kubernetes/custom-5.4.5/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────│─────────────────────────│─────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                        [0m │ [40;32mRULE                   [0m │ [40;32mRESOURCE                           [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────│─────────────────────────│─────────────────────────────────────│────────│────────│
│ 1  │ custom-5-4-5-tls-load-balancer │ check-tls-load-balancer │ v1/Service/default/noncompliant-svc │ Pass   │ Ok     │
│────│────────────────────────────────│─────────────────────────│─────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.5.1/compliant/kyverno-test.yaml`
**Started:** 16:03:55
**Progress:** 53/54 (98.1%)
\n**Duration:** .142129000s
\n```
Loading test  ( tests/kubernetes/custom-5.5.1/compliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────│─────────────────────────│────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                        [0m │ [40;32mRULE                   [0m │ [40;32mRESOURCE                              [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────│─────────────────────────│────────────────────────────────────────│────────│────────│
│ 1  │ custom-5-5-1-iam-authenticator │ check-iam-authenticator │ v1/ServiceAccount/default/compliant-sa │ Pass   │ Ok     │
│────│────────────────────────────────│─────────────────────────│────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
\n## 🧪 Test: `tests/kubernetes/custom-5.5.1/noncompliant/kyverno-test.yaml`
**Started:** 16:03:56
**Progress:** 54/54 (100.0%)
\n**Duration:** .145085000s
\n```
Loading test  ( tests/kubernetes/custom-5.5.1/noncompliant/kyverno-test.yaml ) ...
  Loading values/variables ...
  Loading policies ...
  Loading resources ...
  Loading exceptions ...
  Applying 1 policy to 1 resource with 0 exceptions ...
  Checking results ...

│────│────────────────────────────────│─────────────────────────│───────────────────────────────────────────│────────│────────│
│ [40;32mID[0m │ [40;32mPOLICY                        [0m │ [40;32mRULE                   [0m │ [40;32mRESOURCE                                 [0m │ [40;32mRESULT[0m │ [40;32mREASON[0m │
│────│────────────────────────────────│─────────────────────────│───────────────────────────────────────────│────────│────────│
│ 1  │ custom-5-5-1-iam-authenticator │ check-iam-authenticator │ v1/ServiceAccount/default/noncompliant-sa │ Pass   │ Ok     │
│────│────────────────────────────────│─────────────────────────│───────────────────────────────────────────│────────│────────│


Test Summary: 1 tests passed and 0 tests failed
```
\n---\n
