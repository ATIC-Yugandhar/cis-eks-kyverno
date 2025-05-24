# Kubernetes Runtime Policies

Detailed documentation for all Kubernetes runtime validation policies that enforce CIS EKS Benchmark controls.

## Overview

Runtime policies validate Kubernetes resources as they are created or modified in the cluster. These policies use Kyverno's admission control webhooks to enforce security controls in real-time.

## Policy Categories

### Control Plane Configuration (Section 2)

#### custom-2.1.1 - Enable Audit Logs
Ensures audit logging is configured for the EKS cluster.

```yaml
validate:
  pattern:
    data:
      cluster_logging_types: "*api*audit*"
```

**Validates**: ConfigMap in `kyverno-aws` namespace contains audit configuration
**Action**: Blocks resources without proper audit logging setup

#### custom-2.1.2 - Audit Log Collection
Verifies audit logs are being collected and retained properly.

```yaml
validate:
  pattern:
    data:
      log_collection: "enabled"
      retention_days: ">=30"
```

**Validates**: Log collection configuration meets retention requirements
**Action**: Ensures compliance with log retention policies

### Worker Node Security (Section 3)

#### File Permission Policies (3.1.x)

These policies validate file permissions and ownership on worker nodes:

- **custom-3.1.1**: Kubeconfig permissions (644 or more restrictive)
- **custom-3.1.2**: Kubeconfig ownership (root:root)
- **custom-3.1.3**: Kubelet config permissions (644 or more restrictive)
- **custom-3.1.4**: Kubelet config ownership (root:root)

Example validation pattern:
```yaml
validate:
  pattern:
    metadata:
      annotations:
        file-permissions: "?<=644"
        file-owner: "root:root"
```

#### Kubelet Configuration (3.2.x)

Critical kubelet security settings:

**custom-3.2.1 - Disable Anonymous Auth**
```yaml
validate:
  deny:
    conditions:
      any:
      - key: "{{ request.object.metadata.annotations.\"kubelet-anonymous-auth\" || 'false' }}"
        operator: Equals
        value: "true"
```

**custom-3.2.4 - Disable Read-Only Port**
```yaml
validate:
  pattern:
    metadata:
      annotations:
        kubelet-read-only-port: "0"
```

### RBAC and Service Accounts (Section 4)

#### RBAC Restrictions (4.1.x)

Using Kyverno's built-in policies:

**supported-4.1.1 - Restrict Cluster-Admin**
- Prevents binding cluster-admin to users/groups
- Allows only service accounts in kube-system

**supported-4.1.2 to 4.1.5 - Wildcard Restrictions**
- Prevents use of "*" in verbs, resources, apiGroups
- Enforces least privilege principles

**custom-4.1.8 - Dangerous Permissions**
```yaml
validate:
  deny:
    conditions:
      any:
      - key: "{{ request.object.rules[?contains(verbs, 'bind')] | length(@) }}"
        operator: GreaterThan
        value: 0
```

#### Pod Security Standards (4.2.x)

**supported-4.2.1 - Enforce PSS**
```yaml
validate:
  pattern:
    metadata:
      labels:
        pod-security.kubernetes.io/enforce: "restricted"
```

### Pod Security (Section 5)

#### Image Security (5.1.x)

**custom-5.1.1 - Image Scanning Required**
```yaml
validate:
  pattern:
    metadata:
      annotations:
        image-scan-completed: "true"
        scan-severity: "?contains(['low', 'medium', 'none'])"
```

**Usage**: Ensures all container images are scanned before deployment

#### Network Security (5.4.x)

**custom-5.4.5 - TLS for Load Balancers**
```yaml
validate:
  pattern:
    metadata:
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "?*"
        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "https"
```

## Policy Enforcement Modes

### 1. Audit Mode (Recommended Start)
```yaml
spec:
  validationFailureAction: audit
```
- Logs violations without blocking
- Allows assessment of impact
- Generates PolicyReports

### 2. Warn Mode
```yaml
spec:
  validationFailureAction: warn
```
- Warns users about violations
- Still allows resource creation
- Useful for education phase

### 3. Enforce Mode
```yaml
spec:
  validationFailureAction: enforce
```
- Blocks non-compliant resources
- Provides immediate feedback
- Ensures strict compliance

## Implementation Guide

### Deploying Policies

1. **Test First**:
```bash
kyverno test tests/kubernetes/custom-*/
```

2. **Deploy in Audit Mode**:
```bash
kubectl apply -f policies/kubernetes/
```

3. **Monitor Violations**:
```bash
kubectl get polr -A
```

4. **Gradually Enforce**:
```bash
kubectl patch cpol custom-5-1-1 --type='json' \
  -p='[{"op": "replace", "path": "/spec/validationFailureAction", "value": "enforce"}]'
```

### Policy Exceptions

For legitimate exceptions:

```yaml
apiVersion: kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-kube-system
spec:
  exceptions:
  - policyName: custom-*
    ruleNames: ["*"]
  match:
    any:
    - resources:
        namespaces: ["kube-system"]
```

## Best Practices

### 1. Resource Targeting

Be specific with match criteria:
```yaml
match:
  any:
  - resources:
      kinds: ["Pod"]
      namespaces: ["production", "staging"]
      selector:
        matchLabels:
          app-tier: "backend"
```

### 2. Error Messages

Provide clear, actionable messages:
```yaml
validate:
  message: |
    Pod must have image scanning completed.
    Add annotation: image-scan-completed=true
    after scanning with approved tool.
```

### 3. Performance Optimization

- Use `background: false` for admission-only policies
- Limit match scope to necessary resources
- Avoid complex CEL expressions in hot paths

### 4. Testing Strategy

Always maintain test coverage:
```
tests/kubernetes/
└── custom-5.1.1/
    ├── compliant/
    │   ├── kyverno-test.yaml
    │   ├── pod-with-scan.yaml
    │   └── pod-with-exemption.yaml
    └── noncompliant/
        ├── kyverno-test.yaml
        ├── pod-without-scan.yaml
        └── pod-wrong-severity.yaml
```

## Monitoring and Compliance

### PolicyReports

Query compliance status:
```bash
# Get summary
kubectl get polr -A -o custom-columns=\
NAMESPACE:.metadata.namespace,\
PASS:.summary.pass,\
FAIL:.summary.fail,\
WARN:.summary.warn,\
ERROR:.summary.error

# Get failures
kubectl get polr -A -o json | jq '.items[].results[] | select(.result=="fail")'
```

### Metrics

Key metrics to monitor:
```prometheus
# Policy violations by namespace
sum by (namespace) (kyverno_policy_results_total{result="fail"})

# Admission webhook latency
histogram_quantile(0.99, kyverno_admission_review_duration_seconds_bucket)

# Policy execution errors
rate(kyverno_policy_execution_error_total[5m])
```

## Troubleshooting

### Common Issues

1. **Policy Not Triggering**
   - Check resource matches criteria
   - Verify policy is not in error state
   - Review Kyverno logs

2. **Performance Impact**
   - Review policy complexity
   - Check webhook timeout settings
   - Consider background processing

3. **False Positives**
   - Refine match conditions
   - Add appropriate exceptions
   - Improve validation logic

### Debug Commands

```bash
# Check policy status
kubectl describe cpol custom-5-1-1

# View Kyverno logs
kubectl logs -n kyverno deployment/kyverno -f

# Test specific resource
kyverno apply policies/kubernetes/custom-5.1.1.yaml \
  --resource test-pod.yaml -v 5
```

## Next Steps

- Review [policy limitations](limitations.md) for partial controls
- Explore [Terraform policies](terraform-policies.md) for infrastructure validation
- See [examples](../../examples/) for real-world implementations