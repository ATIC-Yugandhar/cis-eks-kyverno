# Detailed Policy Test Results

Generated: Thu Jun  5 18:26:05 IST 2025

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


## Terraform Policies

### cluster-config

- ❌ require-tags - compliant plan: FAIL
- ✅ require-tags - noncompliant plan: PASS (rejected)

### encryption

- ❌ cis-5.3.1-encrypt-secrets-kms - compliant plan: FAIL
- ✅ cis-5.3.1-encrypt-secrets-kms - noncompliant plan: PASS (rejected)

### monitoring

- ❌ cis-2.1.1-enable-audit-logs - compliant plan: FAIL
- ✅ cis-2.1.1-enable-audit-logs - noncompliant plan: PASS (rejected)

### networking

- ❌ cis-5.4.2-private-endpoint - compliant plan: FAIL
- ✅ cis-5.4.2-private-endpoint - noncompliant plan: PASS (rejected)

- ❌ cis-5.4.3-private-nodes - compliant plan: FAIL
- ✅ cis-5.4.3-private-nodes - noncompliant plan: PASS (rejected)

- ❌ cis-5.4.4-network-policy - compliant plan: FAIL
- ✅ cis-5.4.4-network-policy - noncompliant plan: PASS (rejected)

