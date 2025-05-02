# Enforcing CIS Kubernetes Benchmarks with Kyverno: Drift-Detection-Style Compliance at Scale

![Cover Image: EKS Security and Compliance](https://www.cncf.io/wp-content/uploads/2022/07/Kyverno-horizontal-color.png)

*In today's cloud-native environments, security compliance isn't just a checkbox—it's an ongoing journey. This article demonstrates how to leverage Kyverno's policy engine to implement and enforce CIS EKS Benchmarks through a continuous drift-detection approach, providing scalable compliance across your organization's Kubernetes estate.*

## Introduction: The Compliance Challenge

The Center for Internet Security (CIS) Kubernetes Benchmarks define security best practices for Kubernetes clusters, with specific guidelines tailored for Amazon EKS environments. However, many organizations struggle to translate these benchmarks into actionable, enforceable policies that work in real-world environments.

Traditional approaches to compliance often suffer from:

1. **Point-in-time assessments** that become outdated as soon as new resources are deployed
2. **Manual checklists** that scale poorly across multi-cluster environments
3. **Reactive monitoring** that catches issues after they've already been deployed
4. **Fragmented tooling** between infrastructure-as-code and runtime validation

This article demonstrates how Kyverno—a CNCF-graduated policy engine for Kubernetes—can implement a continuous, drift-detection approach to CIS EKS compliance that spans both infrastructure and workloads.

## Understanding Policy Drift in Kubernetes

Security drift occurs when your running environment diverges from your approved baseline configurations. In Kubernetes, drift can happen through many vectors:

```yaml
# Example: A deployment that drifts from compliance
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: my-app:latest           # Non-compliant: Uses floating tag
        securityContext:
          privileged: true             # Non-compliant: Runs as privileged
          allowPrivilegeEscalation: true # Non-compliant: Allows privilege escalation
        env:
        - name: DB_PASSWORD           # Non-compliant: Secret in env variable
          value: "supersecretvalue"
```

Such configurations might slip through manual reviews or be introduced after initial deployment. Kyverno can detect these drifts both in pre-deployment validation and in periodic cluster scanning.

## Anchoring to Git + Kyverno CLI

A key benefit of Kyverno is its ability to run both inside clusters and as a CLI tool for offline validation. This enables "shift-left" security practices where infrastructure and application manifests can be validated before they're applied to a cluster:

```bash
$ ./scripts/validate-cis.sh
Validating resources against CIS policies...

Running Kyverno CLI tests for supported policies...
testing: cis-4.1.1-test.yaml
testing: cis-4.1.2-test.yaml
...
PASS: 16/16 policies passed

Running Kyverno CLI tests for custom policies...
testing: cis-4.5.1-custom-test.yaml
...
PASS: 3/3 policies passed

Validating Terraform plan against Kyverno policies...
Generating Terraform plan...
Plan: 17 to add, 0 to change, 0 to destroy.

policy cis-2.1.1-enable-audit-logs -> resource default/testing-policy/terraform-plan PASSED
policy cis-5.3.1-encrypt-secrets-with-kms -> resource default/testing-policy/terraform-plan PASSED
...
PASS: 23/23 policies passed
```

This unified approach anchors all compliance checks back to Git, ensuring a consistent source of truth whether validating Terraform plans or evaluating running clusters.

## Out-of-the-Box Coverage

Kyverno provides comprehensive out-of-the-box coverage for many CIS EKS Benchmark controls, particularly those focused on workload security:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cis-4.2.1-disallow-privileged-containers
  annotations:
    policies.kyverno.io/title: Disallow Privileged Containers
    policies.kyverno.io/category: CIS Benchmarks
spec:
  validationFailureAction: enforce
  rules:
  - name: privileged-containers
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Privileged containers are not allowed."
      pattern:
        spec:
          containers:
          - name: "*"
            securityContext:
              privileged: false
```

The beauty of Kyverno lies in its Kubernetes-native approach—policies are defined as custom resources and can be managed through the same GitOps workflows as your applications.

## Bridging Gaps with Custom Policies

For EKS-specific controls that aren't covered by default policies, we've developed custom rules:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: terraform-cis-5.3.1-encrypt-secrets-with-kms
  annotations:
    policies.kyverno.io/title: "Terraform CIS 5.3.1 - Encrypt Kubernetes Secrets with KMS CMKs"
spec:
  validationFailureAction: audit
  rules:
    - name: eks-secrets-encryption
      match:
        resources:
          kinds:
            - TerraformPlan
      validate:
        message: "EKS clusters must have secrets encryption enabled with KMS CMKs."
        pattern:
          plan:
            resource_changes:
              - type: aws_eks_cluster
                change:
                  after:
                    encryption_config:
                      - resources:
                          - "secrets"
                        provider:
                          key_arn: "*"
```

This policy scans Terraform plans to ensure EKS clusters encrypt secrets with AWS KMS customer master keys—an infrastructure-level control that complements the runtime validations.

## CI/CD Integration: Continuous Compliance

The real power of Kyverno for CIS compliance comes from its integration into CI/CD pipelines. Here's how a complete GitHub Actions workflow might look:

```yaml
name: EKS CIS Compliance

on:
  push:
    paths:
      - 'terraform/**'
      - 'kubernetes/**'

jobs:
  validate-terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Kyverno CLI
        run: |
          curl -LO https://github.com/kyverno/kyverno/releases/download/v1.10.0/kyverno-cli_v1.10.0_linux_x86_64.tar.gz
          tar -xvf kyverno-cli_v1.10.0_linux_x86_64.tar.gz
          sudo mv kyverno /usr/local/bin/
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform -chdir=terraform init -backend=false
      
      - name: Terraform Plan
        run: terraform -chdir=terraform plan -out=tfplan.out
      
      - name: Export Plan JSON
        run: terraform -chdir=terraform show -json tfplan.out > tfplan.json
      
      - name: Validate with Kyverno
        run: kyverno apply kyverno-policies/terraform --resource terraform/tfplan.json
  
  validate-kubernetes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Kyverno CLI
        run: |
          curl -LO https://github.com/kyverno/kyverno/releases/download/v1.10.0/kyverno-cli_v1.10.0_linux_x86_64.tar.gz
          tar -xvf kyverno-cli_v1.10.0_linux_x86_64.tar.gz
          sudo mv kyverno /usr/local/bin/
      
      - name: Validate Kubernetes manifests
        run: kyverno apply kyverno-policies/cis/supported --resource kubernetes/
```

This workflow ensures that both infrastructure and application manifests are validated before they're deployed, creating a continuous compliance posture.

## Lessons Learned & Best Practices

After implementing CIS EKS Benchmark controls across multiple environments, we've identified several best practices:

1. **Layer your policies**: Use different validationFailureAction values ("audit" vs. "enforce") to gradually introduce policies
2. **Start with the high-impact controls**: Security context restrictions, RBAC limitations, and secret management provide the most immediate value
3. **Blend IaC and runtime validation**: Some controls are best enforced in Terraform, others at the Kubernetes manifest level
4. **Measure and report**: Use the PolicyReport resources to generate compliance dashboards and track your security posture over time
5. **Generate exceptions through code**: Rather than disabling policies, use Kyverno's exception mechanisms for authorized deviations

With these practices, we've been able to maintain continuous compliance across our entire EKS fleet.

## Conclusion & Next Steps

Kyverno offers a comprehensive approach to implementing CIS EKS Benchmarks across the entire application lifecycle:

- **Shift-left validation** of Terraform infrastructure and Kubernetes manifests
- **Runtime enforcement** of security policies through admission control
- **Continuous auditing** via PolicyReports and integration with security tools
- **Unified policy language** across infrastructure and workload validation

We've provided a complete implementation covering all 45 controls from the CIS EKS Benchmark, combining 16 Kubernetes policies with 23 Terraform validation policies to deliver end-to-end coverage.

By treating compliance as code and leveraging Kyverno's drift-detection capabilities, your organization can ensure that not only the initial deployment but all subsequent changes maintain alignment with CIS best practices.

---

*About the Author: This article was contributed by the Cloud Security team at [Your Organization], specializing in containerized security compliance at scale.*

---

## Resources

- [GitHub Repository](https://github.com/ATIC-Yugandhar/cis-eks-kyverno) - Complete implementation of all policies described in this article
- [CIS EKS Benchmark](https://www.cisecurity.org/benchmark/kubernetes) - Official CIS documentation
- [Kyverno Documentation](https://kyverno.io/docs/) - Official Kyverno documentation