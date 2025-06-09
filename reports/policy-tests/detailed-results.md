# Detailed Policy Test Results

Generated: Mon Jun  9 10:25:05 IST 2025

## Kubernetes Policies

### control-plane

- ✅ custom-2.1.1 - compliant: PASS
- ✅ custom-2.1.1 - noncompliant: PASS (rejected)

- ✅ custom-2.1.2 - compliant: PASS
- ✅ custom-2.1.2 - noncompliant: PASS (rejected)

### pod-security

- ✅ custom-5.1.1 - compliant: PASS
- ✅ custom-5.1.1 - noncompliant: PASS (rejected)

- ✅ custom-5.1.2 - compliant: PASS
- ✅ custom-5.1.2 - noncompliant: PASS (rejected)

- ✅ custom-5.1.3 - compliant: PASS
- ✅ custom-5.1.3 - noncompliant: PASS (rejected)

- ⏭️ custom-5.3.1 - compliant: SKIPPED (JSON test)
- ✅ custom-5.3.1 - noncompliant: PASS (rejected)

- ✅ custom-5.4.1 - compliant: PASS
- ✅ custom-5.4.1 - noncompliant: PASS (rejected)

- ✅ custom-5.4.2 - compliant: PASS
- ✅ custom-5.4.2 - noncompliant: PASS (rejected)

- ✅ custom-5.4.3 - compliant: PASS
- ✅ custom-5.4.3 - noncompliant: PASS (rejected)

- ✅ custom-5.4.5 - compliant: PASS
- ✅ custom-5.4.5 - noncompliant: PASS (rejected)

- ✅ custom-5.5.1 - compliant: PASS
- ✅ custom-5.5.1 - noncompliant: PASS (rejected)

### rbac

- ✅ custom-4.1.7 - compliant: PASS
- ✅ custom-4.1.7 - noncompliant: PASS (rejected)

- ✅ custom-4.1.8 - compliant: PASS
- ✅ custom-4.1.8 - noncompliant: PASS (rejected)

- ✅ custom-4.3.1 - compliant: PASS
- ✅ custom-4.3.1 - noncompliant: PASS (rejected)

- ✅ custom-4.4.2 - compliant: PASS
- ✅ custom-4.4.2 - noncompliant: PASS (rejected)

- ⏭️ custom-4.5.1 - compliant: SKIPPED (namespace policy)
- ✅ custom-4.5.1 - noncompliant: PASS (rejected)

- ✅ supported-4.1.1 - compliant: PASS
- ✅ supported-4.1.1 - noncompliant: PASS (rejected)

- ❌ supported-4.1.2 - compliant: FAIL
- ✅ supported-4.1.2 - noncompliant: PASS (rejected)

- ❌ supported-4.1.3 - compliant: FAIL
- ✅ supported-4.1.3 - noncompliant: PASS (rejected)

- ✅ supported-4.1.4 - compliant: PASS
- ✅ supported-4.1.4 - noncompliant: PASS (rejected)

- ✅ supported-4.1.5 - compliant: PASS
- ✅ supported-4.1.5 - noncompliant: PASS (rejected)

- ✅ supported-4.1.6 - compliant: PASS
- ✅ supported-4.1.6 - noncompliant: PASS (rejected)

- ✅ supported-4.2.1 - compliant: PASS
- ✅ supported-4.2.1 - noncompliant: PASS (rejected)

- ❌ supported-4.2.2 - compliant: FAIL
- ✅ supported-4.2.2 - noncompliant: PASS (rejected)

- ❌ supported-4.2.3 - compliant: FAIL
- ✅ supported-4.2.3 - noncompliant: PASS (rejected)

- ❌ supported-4.2.4 - compliant: FAIL
- ✅ supported-4.2.4 - noncompliant: PASS (rejected)

### worker-nodes

- ✅ custom-3.1.1 - compliant: PASS
- ✅ custom-3.1.1 - noncompliant: PASS (rejected)

- ✅ custom-3.1.2 - compliant: PASS
- ✅ custom-3.1.2 - noncompliant: PASS (rejected)

- ✅ custom-3.1.3 - compliant: PASS
- ✅ custom-3.1.3 - noncompliant: PASS (rejected)

- ✅ custom-3.1.4 - compliant: PASS
- ✅ custom-3.1.4 - noncompliant: PASS (rejected)

- ✅ custom-3.2.1 - compliant: PASS
- ✅ custom-3.2.1 - noncompliant: PASS (rejected)

- ✅ custom-3.2.2 - compliant: PASS
- ✅ custom-3.2.2 - noncompliant: PASS (rejected)

- ✅ custom-3.2.3 - compliant: PASS
- ✅ custom-3.2.3 - noncompliant: PASS (rejected)

- ✅ custom-3.2.4 - compliant: PASS
- ✅ custom-3.2.4 - noncompliant: PASS (rejected)

- ✅ custom-3.2.5 - compliant: PASS
- ✅ custom-3.2.5 - noncompliant: PASS (rejected)

- ✅ custom-3.2.6 - compliant: PASS
- ✅ custom-3.2.6 - noncompliant: PASS (rejected)

- ✅ custom-3.2.7 - compliant: PASS
- ✅ custom-3.2.7 - noncompliant: PASS (rejected)

- ✅ custom-3.2.8 - compliant: PASS
- ✅ custom-3.2.8 - noncompliant: PASS (rejected)

- ✅ custom-3.2.9 - compliant: PASS
- ✅ custom-3.2.9 - noncompliant: PASS (rejected)


## OpenTofu Policies

### cluster-config

- ❌ cis-5.5.1-iam-authenticator - compliant plan: FAIL
- ✅ cis-5.5.1-iam-authenticator - noncompliant plan: PASS (rejected)

- ❌ cis-5.5.1-resource-quotas - compliant plan: FAIL
- ✅ cis-5.5.1-resource-quotas - noncompliant plan: PASS (rejected)

- ❌ require-tags - compliant plan: FAIL
- ✅ require-tags - noncompliant plan: PASS (rejected)

### control-plane

- ❌ cis-2.1.2-audit-log-destinations - compliant plan: FAIL
- ✅ cis-2.1.2-audit-log-destinations - noncompliant plan: PASS (rejected)

- ❌ cis-2.1.3-audit-log-retention - compliant plan: FAIL
- ✅ cis-2.1.3-audit-log-retention - noncompliant plan: PASS (rejected)

- ❌ cis-2.2.1-authorization-mode - compliant plan: FAIL
- ✅ cis-2.2.1-authorization-mode - noncompliant plan: PASS (rejected)

### encryption

- ❌ cis-5.3.1-encrypt-secrets-kms - compliant plan: FAIL
- ✅ cis-5.3.1-encrypt-secrets-kms - noncompliant plan: PASS (rejected)

- ❌ cis-5.3.2-secrets-management - compliant plan: FAIL
- ✅ cis-5.3.2-secrets-management - noncompliant plan: PASS (rejected)

### monitoring

- ❌ cis-2.1.1-enable-audit-logs - compliant plan: FAIL
- ✅ cis-2.1.1-enable-audit-logs - noncompliant plan: PASS (rejected)

- ❌ cis-5.1.1-image-scanning - compliant plan: FAIL
- ✅ cis-5.1.1-image-scanning - noncompliant plan: PASS (rejected)

### networking

- ❌ cis-4.3.1-network-policy-support - compliant plan: FAIL
- ✅ cis-4.3.1-network-policy-support - noncompliant plan: PASS (rejected)

- ❌ cis-5.1.1-security-group-rules - compliant plan: FAIL
- ✅ cis-5.1.1-security-group-rules - noncompliant plan: PASS (rejected)

- ❌ cis-5.1.2-nacl-configuration - compliant plan: FAIL
- ✅ cis-5.1.2-nacl-configuration - noncompliant plan: PASS (rejected)

- ❌ cis-5.4.2-private-endpoint - compliant plan: FAIL
- ✅ cis-5.4.2-private-endpoint - noncompliant plan: PASS (rejected)

- ❌ cis-5.4.3-private-nodes - compliant plan: FAIL
- ✅ cis-5.4.3-private-nodes - noncompliant plan: PASS (rejected)

- ❌ cis-5.4.4-network-policy - compliant plan: FAIL
- ✅ cis-5.4.4-network-policy - noncompliant plan: PASS (rejected)

### rbac

- ❌ cis-4.1.1-minimize-cluster-admin - compliant plan: FAIL
- ✅ cis-4.1.1-minimize-cluster-admin - noncompliant plan: PASS (rejected)

- ❌ cis-4.1.2-minimize-secrets-access - compliant plan: FAIL
- ✅ cis-4.1.2-minimize-secrets-access - noncompliant plan: PASS (rejected)

- ❌ cis-4.1.3-minimize-wildcard-permissions - compliant plan: FAIL
- ✅ cis-4.1.3-minimize-wildcard-permissions - noncompliant plan: PASS (rejected)

- ❌ cis-4.1.4-minimize-pod-creation-access - compliant plan: FAIL
- ✅ cis-4.1.4-minimize-pod-creation-access - noncompliant plan: PASS (rejected)

- ❌ cis-4.1.8-restrict-bind-impersonate-escalate - compliant plan: FAIL
- ✅ cis-4.1.8-restrict-bind-impersonate-escalate - noncompliant plan: PASS (rejected)

- ❌ cis-5.1.2-ecr-access-minimization - compliant plan: FAIL
- ✅ cis-5.1.2-ecr-access-minimization - noncompliant plan: PASS (rejected)

### worker-nodes

- ❌ cis-3.1.1-worker-node-security - compliant plan: FAIL
- ✅ cis-3.1.1-worker-node-security - noncompliant plan: PASS (rejected)

