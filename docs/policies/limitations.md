# Policy Limitations and Unenforceable Controls

This document details CIS EKS Benchmark controls that cannot be fully enforced by Kyverno policies, along with explanations and recommended alternative approaches.

## Overview

While Kyverno provides powerful policy enforcement capabilities, certain CIS controls have limitations due to:

- **Plan-time constraints**: Some values are only known after Terraform apply
- **Runtime dependencies**: Controls requiring external system validation
- **AWS-specific features**: Controls that depend on AWS API responses
- **External integrations**: Controls involving third-party systems

## Unenforceable Controls Summary

| CIS ID | Control | Enforcement Level | Alternative Approach |
|--------|---------|-------------------|---------------------|
| 4.1.7 | Cluster Access Manager API | Partial | AWS IAM validation |
| 4.3.1 | CNI Plugin Network Policies | None | Manual CNI verification |
| 4.4.2 | External Secret Storage | None | External tool integration |
| 5.1.1 | Image Scanning in ECR | Partial | ECR scan results API |
| 5.1.2 | Minimize ECR User Access | Partial | IAM policy analysis |
| 5.1.3 | Limit Cluster ECR to Read-Only | Partial | IAM policy analysis |
| 5.4.1 | Restrict Control Plane Access | Full* | Terraform plan validation |
| 5.4.3 | Deploy Private Nodes | Partial | AWS EC2 validation |
| 5.4.5 | TLS for Load Balancer Traffic | Partial | AWS ALB/NLB validation |
| 5.5.1 | Manage Users via IAM | Partial | aws-auth ConfigMap review |

*Full enforcement possible if configured in Terraform

## Detailed Analysis

### 4.1.7 - Use Cluster Access Manager API

**Challenge**: Full enforcement requires AWS IAM/API access validation.

**Current Capability**: 
- Can validate `aws_eks_access_entry` configurations if defined in Terraform plan
- Cannot verify actual IAM permissions or API usage

**Recommended Approach**:
```yaml
# Partial validation policy
apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
metadata:
  name: partial-cluster-access-validation
spec:
  rules:
    - name: check-access-entries
      assert:
        all:
        - message: "EKS Access Entries should be configured"
          check:
            ~.(planned_values.root_module.resources[?type=='aws_eks_access_entry']):
              values.principal_arn: "?*"
```

**Alternative**: Use AWS Config rules or custom Lambda functions to validate IAM configurations.

### 4.3.1 - Ensure CNI Plugin Supports Network Policies

**Challenge**: CNI plugin configuration is outside Terraform plan scope.

**Current Capability**: None - CNI plugins are installed post-cluster creation.

**Recommended Approach**:
- Document required CNI plugin (e.g., Calico, Cilium)
- Validate CNI installation in post-deployment tests
- Use runtime policies to ensure NetworkPolicy resources exist

```bash
# Post-deployment validation script
kubectl get daemonset -n kube-system | grep -E "calico|cilium|weave"
```

### 4.4.2 - Use External Secret Storage

**Challenge**: External secret management systems are not Terraform/Kubernetes resources.

**Current Capability**: 
- Can validate presence of secret management annotations
- Cannot verify actual external storage integration

**Recommended Approach**:
```yaml
# Runtime validation for external secret annotations
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-external-secrets
spec:
  rules:
    - name: check-external-secret-annotation
      match:
        resources:
          kinds: ["Secret"]
      validate:
        pattern:
          metadata:
            annotations:
              external-secrets.io/managed: "true"
```

### 5.1.1 - Enable Image Scanning in ECR

**Challenge**: Full enforcement requires ECR API validation.

**Current Capability**:
- Can verify `scan_on_push` setting in Terraform-managed ECR repositories
- Cannot check actual scan results or third-party scanners

**Terraform Plan Validation**:
```yaml
apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
spec:
  rules:
    - name: check-ecr-scanning
      assert:
        all:
        - check:
            ~.(planned_values.root_module.resources[?type=='aws_ecr_repository']):
              values.image_scanning_configuration.scan_on_push: true
```

**Alternative**: Integrate with ECR scanning API or use admission controllers like Grafeas.

### 5.1.2 & 5.1.3 - ECR Access Controls

**Challenge**: IAM policy evaluation is complex and subjective.

**Current Capability**:
- Can validate IAM policy documents if defined in Terraform
- Cannot fully evaluate effective permissions

**Recommended Approach**:
1. Use AWS IAM Policy Simulator
2. Implement least-privilege IAM policies
3. Regular access reviews using AWS Access Analyzer

### 5.4.1 - Restrict Control Plane Endpoint Access

**Challenge**: Depends on EKS cluster configuration availability.

**Current Capability**: 
- **Full enforcement** if EKS settings are in Terraform plan
- Can validate `endpoint_public_access` and `public_access_cidrs`

**Full Validation Policy**:
```yaml
apiVersion: json.kyverno.io/v1alpha1
kind: ValidatingPolicy
spec:
  rules:
    - name: restrict-public-access
      assert:
        all:
        - message: "Public endpoint should be disabled or restricted"
          check:
            ~.(planned_values.root_module.resources[?type=='aws_eks_cluster']):
              values:
                (endpoint_public_access == `false` || (public_access_cidrs | length(@) > `0` && !contains(@, '0.0.0.0/0'))): true
```

### 5.4.3 - Deploy Private Nodes

**Challenge**: Node deployment is managed by AWS managed node groups.

**Current Capability**:
- Can validate subnet associations in Terraform
- Cannot guarantee node placement

**Recommended Approach**:
- Validate private subnet usage in node group configuration
- Use AWS Systems Manager to verify node network configuration

### 5.4.5 - Use TLS to Encrypt Load Balancer Traffic

**Challenge**: Load balancer configuration may be outside Terraform scope.

**Current Capability**:
- Can validate ALB/NLB listeners if defined in Terraform
- Can check Service annotations for AWS load balancer SSL

**Runtime Validation**:
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-tls-load-balancer
spec:
  rules:
    - name: check-tls-annotation
      match:
        resources:
          kinds: ["Service"]
          selector:
            matchLabels:
              type: LoadBalancer
      validate:
        pattern:
          metadata:
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "?*"
              service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "https"
```

### 5.5.1 - Manage Users via IAM Authenticator

**Challenge**: User management involves multiple AWS services.

**Current Capability**:
- Can validate aws-auth ConfigMap if managed via Terraform
- Can check for EKS Access Entries

**Recommended Approach**:
1. Audit aws-auth ConfigMap regularly
2. Use EKS Access Entries for new user management
3. Implement RBAC policies for authorization

## Plan-Time Limitations

### General Constraints

1. **Computed Values**: Resources with values determined during apply
2. **Dynamic Resources**: Resources created by AWS (e.g., default security groups)
3. **External Dependencies**: Resources managed outside Terraform
4. **Runtime State**: Actual cluster state vs. planned state

### Mitigation Strategies

1. **Two-Phase Validation**:
   ```bash
   # Phase 1: Pre-deployment
   terraform plan -out=plan.tfplan
   kyverno apply policies/terraform/ --resource plan.json
   
   # Phase 2: Post-deployment
   kubectl apply -f runtime-validation-job.yaml
   ```

2. **Complementary Tools**:
   - AWS Config for AWS resource compliance
   - Open Policy Agent (OPA) for complex policy logic
   - Falco for runtime security monitoring
   - Grafeas for vulnerability management

3. **Custom Validation Scripts**:
   ```bash
   # Example: Validate CNI after deployment
   #!/bin/bash
   CNI_READY=$(kubectl get ds -n kube-system -o json | jq '.items[] | select(.metadata.name | contains("calico"))')
   if [ -z "$CNI_READY" ]; then
     echo "ERROR: Network policy CNI not found"
     exit 1
   fi
   ```

## Testing Considerations

### Automated Testing Limitations

The `test-all-policies.sh` script validates policy syntax and logic but:
- Cannot test AWS API interactions
- Cannot verify external system integrations
- May show false positives for partial enforcements

### Test Enhancement Recommendations

1. **Integration Tests**: Include AWS API validation
2. **Smoke Tests**: Post-deployment verification
3. **Compliance Scanning**: Regular AWS Config rule evaluation
4. **Security Audits**: Periodic manual reviews

## Recommendations

### For Full Compliance

1. **Layer Security Controls**:
   - Plan-time validation (prevent misconfigurations)
   - Runtime enforcement (continuous compliance)
   - Periodic audits (catch drift)

2. **Use Multiple Tools**:
   - Kyverno for Kubernetes-native policies
   - AWS Config for AWS resource compliance
   - CloudTrail for audit logging
   - GuardDuty for threat detection

3. **Implement Compensating Controls**:
   - For unenforceable controls, document manual procedures
   - Create automated alerts for configuration drift
   - Regular compliance reviews and reports

### Documentation Requirements

For each partially enforceable control:
1. Document what is validated automatically
2. Specify manual verification steps
3. Provide scripts or queries for validation
4. Set up monitoring and alerting

## Conclusion

While not all CIS controls can be fully enforced through Kyverno policies, the framework provides substantial coverage for both plan-time and runtime validation. By understanding these limitations and implementing complementary controls, organizations can achieve comprehensive compliance with the CIS EKS Benchmark.

For controls marked as "Partial" enforcement, always supplement automated validation with:
- Manual reviews
- AWS-native compliance tools
- Custom validation scripts
- Regular security audits

Remember: Security is a layered approach, and policy enforcement is just one layer in a comprehensive security strategy.