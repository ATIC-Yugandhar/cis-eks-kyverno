# 🧪 Kyverno Policy Test Results

**Comprehensive test results for all CIS EKS compliance policies**

---

## 📊 Executive Summary

| Metric | Value |
|--------|-------|
| **Total Tests** | 54 |
| **✅ Passed** | 53 |
| **❌ Failed** | 0 |
| **⚠️ Errors** | 1 |
| **Success Rate** | 98.1% |
| **Total Duration** | 14.846s |

---

## 📋 Detailed Test Results

\n## 🧪 Test: `tests/kubernetes/custom-2.1.1/compliant/kyverno-test.yaml`
**Started:** 16:22:32
**Progress:** 1/54 (1.9%)
\n**Duration:** 0.139s
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
**Started:** 16:22:33
**Progress:** 2/54 (3.7%)
\n**Duration:** 0.140s
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
**Started:** 16:22:33
**Progress:** 3/54 (5.6%)
\n**Duration:** 0.145s
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
**Started:** 16:22:33
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
**Started:** 16:22:33
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
**Started:** 16:22:34
**Progress:** 6/54 (11.1%)
\n**Duration:** 0.150s
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
**Started:** 16:22:34
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
**Started:** 16:22:34
**Progress:** 8/54 (14.8%)
\n**Duration:** 0.147s
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
**Started:** 16:22:34
**Progress:** 9/54 (16.7%)
\n**Duration:** 0.141s
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
**Started:** 16:22:35
**Progress:** 10/54 (18.5%)
\n**Duration:** 0.146s
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
**Started:** 16:22:35
**Progress:** 11/54 (20.4%)
\n**Duration:** 0.143s
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
**Started:** 16:22:35
**Progress:** 12/54 (22.2%)
\n**Duration:** 0.142s
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
**Started:** 16:22:36
**Progress:** 13/54 (24.1%)
\n**Duration:** 0.238s
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
**Started:** 16:22:36
**Progress:** 14/54 (25.9%)
\n**Duration:** 0.243s
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
**Started:** 16:22:36
**Progress:** 15/54 (27.8%)
\n**Duration:** 0.143s
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
**Started:** 16:22:37
**Progress:** 16/54 (29.6%)
\n**Duration:** 0.144s
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
**Started:** 16:22:37
**Progress:** 17/54 (31.5%)
\n**Duration:** 0.144s
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
**Started:** 16:22:37
**Progress:** 18/54 (33.3%)
\n**Duration:** 0.146s
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
**Started:** 16:22:37
**Progress:** 19/54 (35.2%)
\n**Duration:** 0.142s
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
**Started:** 16:22:38
**Progress:** 20/54 (37.0%)
\n**Duration:** 0.144s
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
**Started:** 16:22:38
**Progress:** 21/54 (38.9%)
\n**Duration:** 0.144s
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
**Started:** 16:22:38
**Progress:** 22/54 (40.7%)
\n**Duration:** 0.146s
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
**Started:** 16:22:38
**Progress:** 23/54 (42.6%)
\n**Duration:** 0.143s
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
**Started:** 16:22:39
**Progress:** 24/54 (44.4%)
\n**Duration:** 0.142s
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
**Started:** 16:22:39
**Progress:** 25/54 (46.3%)
\n**Duration:** 0.139s
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
**Started:** 16:22:39
**Progress:** 26/54 (48.1%)
\n**Duration:** 0.145s
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
**Started:** 16:22:39
**Progress:** 27/54 (50.0%)
\n**Duration:** 0.138s
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
**Started:** 16:22:40
**Progress:** 28/54 (51.9%)
\n**Duration:** 0.143s
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
**Started:** 16:22:40
**Progress:** 29/54 (53.7%)
\n**Duration:** 0.147s
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
**Started:** 16:22:40
**Progress:** 30/54 (55.6%)
\n**Duration:** 0.144s
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
**Started:** 16:22:41
**Progress:** 31/54 (57.4%)
\n**Duration:** 0.146s
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
**Started:** 16:22:41
**Progress:** 32/54 (59.3%)
\n**Duration:** 0.149s
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
**Started:** 16:22:41
**Progress:** 33/54 (61.1%)
\n**Duration:** 0.144s
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
**Started:** 16:22:41
**Progress:** 34/54 (63.0%)
\n**Duration:** 0.145s
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
**Started:** 16:22:42
**Progress:** 35/54 (64.8%)
\n**Duration:** 0.142s
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
**Started:** 16:22:42
**Progress:** 36/54 (66.7%)
\n**Duration:** 0.146s
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
**Started:** 16:22:42
**Progress:** 37/54 (68.5%)
\n**Duration:** 0.145s
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
**Started:** 16:22:42
**Progress:** 38/54 (70.4%)
\n**Duration:** 0.141s
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
**Started:** 16:22:43
**Progress:** 39/54 (72.2%)
\n**Duration:** 0.146s
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
**Started:** 16:22:43
**Progress:** 40/54 (74.1%)
\n**Duration:** 0.146s
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
**Started:** 16:22:43
**Progress:** 41/54 (75.9%)
\n**Duration:** 0.242s
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
**Started:** 16:22:44
**Progress:** 42/54 (77.8%)
\n**Duration:** 0.240s
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
**Started:** 16:22:44
**Progress:** 43/54 (79.6%)
\n**Duration:** 0.143s
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
**Started:** 16:22:44
**Progress:** 44/54 (81.5%)
\n**Duration:** 0.146s
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
**Started:** 16:22:44
**Progress:** 45/54 (83.3%)
\n**Duration:** 0.144s
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
**Started:** 16:22:45
**Progress:** 46/54 (85.2%)
\n**Duration:** 0.144s
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
**Started:** 16:22:45
**Progress:** 47/54 (87.0%)
\n**Duration:** 0.146s
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
**Started:** 16:22:45
**Progress:** 48/54 (88.9%)
\n**Duration:** 0.142s
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
**Started:** 16:22:46
**Progress:** 49/54 (90.7%)
\n**Duration:** 0.144s
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
**Started:** 16:22:46
**Progress:** 50/54 (92.6%)
\n**Duration:** 0.143s
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
**Started:** 16:22:46
**Progress:** 51/54 (94.4%)
\n**Duration:** 0.145s
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
**Started:** 16:22:46
**Progress:** 52/54 (96.3%)
\n**Duration:** 0.143s
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
**Started:** 16:22:47
**Progress:** 53/54 (98.1%)
\n**Duration:** 0.145s
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
**Started:** 16:22:47
**Progress:** 54/54 (100.0%)
\n**Duration:** 0.145s
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
