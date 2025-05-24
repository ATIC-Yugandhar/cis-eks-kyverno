# Step-by-Step Tutorial

A comprehensive guide to implementing CIS EKS Benchmark compliance using Kyverno.

## Table of Contents
1. [Environment Setup](#environment-setup)
2. [Understanding the Framework](#understanding-the-framework)
3. [Local Policy Testing](#local-policy-testing)
4. [Kubernetes Runtime Validation](#kubernetes-runtime-validation)
5. [Terraform Plan-time Validation](#terraform-plan-time-validation)
6. [Production Deployment](#production-deployment)
7. [Monitoring and Reporting](#monitoring-and-reporting)
8. [Troubleshooting](#troubleshooting)

## Environment Setup

### 1. Prepare Your Workspace

```bash
# Create a working directory
mkdir -p ~/cis-eks-compliance
cd ~/cis-eks-compliance

# Clone the repository
git clone https://github.com/your-org/cis-eks-kyverno.git
cd cis-eks-kyverno

# Verify the structure
tree -L 2
```

### 2. Install Required Tools

```bash
# Run the prerequisites check
./scripts/check-prerequisites.sh

# If any tools are missing, install them:
# Kyverno CLI
curl -L https://github.com/kyverno/kyverno/releases/latest/download/kyverno-cli_linux_x86_64.tar.gz | tar -xz
sudo mv kyverno /usr/local/bin/

# Verify installation
kyverno version
```

### 3. Set Up Test Environment (Optional)

```bash
# Create a local Kubernetes cluster with Kind
kind create cluster --name cis-test --config demo-kind-kyverno/kind-cluster-config.yaml

# Verify cluster access
kubectl cluster-info
kubectl get nodes
```

## Understanding the Framework

### Policy Structure

Each CIS control is implemented as a Kyverno policy with the following structure:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: cis-5-1-1-image-scanning
  annotations:
    policies.kyverno.io/title: "Ensure Image Vulnerability Scanning"
    policies.kyverno.io/category: "Pod Security Standards"
    policies.kyverno.io/cis-control: "5.1.1"
spec:
  validationFailureAction: audit  # Start with audit mode
  background: true
  rules:
    - name: check-image-scanning
      match:
        any:
        - resources:
            kinds:
            - Pod
      validate:
        message: "Images must be scanned for vulnerabilities"
        pattern:
          metadata:
            annotations:
              image-scan-completed: "true"
```

### Test Structure

Each policy has corresponding tests:

```
tests/kubernetes/custom-5.1.1/
├── compliant/
│   ├── kyverno-test.yaml      # Test configuration
│   └── pod.yaml               # Compliant resource
└── noncompliant/
    ├── kyverno-test.yaml      # Test configuration
    └── pod.yaml               # Non-compliant resource
```

## Local Policy Testing

### Step 1: Run All Policy Tests

```bash
# Execute the comprehensive test suite
./scripts/test-all-policies.sh

# Review the results
cat reports/policy-tests/summary.md
```

### Step 2: Test Individual Policies

```bash
# Test a specific control
kyverno test tests/kubernetes/custom-5.1.1/

# Expected output for successful test:
# Test Summary: 1 tests passed and 0 tests failed
```

### Step 3: Validate Your Own Resources

```bash
# Create a test pod manifest
cat > my-test-pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx:latest
EOF

# Validate against specific policy
kyverno apply policies/kubernetes/pod-security/custom-5.1.1.yaml --resource my-test-pod.yaml

# Fix any violations and re-test
```

## Kubernetes Runtime Validation

### Step 1: Install Kyverno in Your Cluster

```bash
# Install Kyverno
kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml

# Wait for Kyverno to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=kyverno -n kyverno --timeout=300s

# Verify installation
kubectl get pods -n kyverno
```

### Step 2: Deploy CIS Policies in Audit Mode

```bash
# Apply all policies in audit mode
kubectl apply -f policies/kubernetes/

# Verify policies are loaded
kubectl get clusterpolicies | grep cis

# Check policy status
kubectl describe cpol cis-5-1-1-image-scanning
```

### Step 3: Monitor Policy Violations

```bash
# View policy violations
kubectl get policyreport -A

# Get detailed violation report
kubectl describe polr -n default

# Export violations to file
kubectl get events --field-selector reason=PolicyViolation -A -o json > violations.json
```

### Step 4: Gradual Enforcement

```bash
# After reviewing violations, enforce specific policies
kubectl patch cpol cis-5-1-1-image-scanning --type='json' \
  -p='[{"op": "replace", "path": "/spec/validationFailureAction", "value": "enforce"}]'

# Test enforcement
kubectl apply -f tests/kubernetes/custom-5.1.1/noncompliant/pod.yaml
# Should be rejected
```

## Terraform Plan-time Validation

### Step 1: Prepare Terraform Configuration

```bash
cd terraform/compliant

# Initialize Terraform
terraform init

# Create a plan
terraform plan -out=tfplan.binary

# Convert to JSON for validation
terraform show -json tfplan.binary > tfplan.json
```

### Step 2: Validate Terraform Plan

```bash
# Enable experimental features
export KYVERNO_EXPERIMENTAL=true

# Run validation
kyverno apply policies/terraform/ --resource tfplan.json

# Check specific controls
kyverno apply policies/terraform/cis-5.3.1-encrypt-secrets-kms.yaml --resource tfplan.json
```

### Step 3: Integrate into CI/CD

```yaml
# .github/workflows/terraform-compliance.yml
name: Terraform CIS Compliance

on:
  pull_request:
    paths:
      - 'terraform/**'

jobs:
  compliance-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Terraform Plan
        run: |
          cd terraform
          terraform init
          terraform plan -out=tfplan.binary
          terraform show -json tfplan.binary > tfplan.json
          
      - name: CIS Compliance Check
        run: |
          export KYVERNO_EXPERIMENTAL=true
          kyverno apply policies/terraform/ --resource tfplan.json
```

## Production Deployment

### Step 1: Plan Your Rollout

```bash
# Create a deployment plan
cat > deployment-plan.md <<EOF
## CIS EKS Compliance Rollout Plan

### Phase 1: Audit Mode (Week 1-2)
- Deploy all policies in audit mode
- Monitor violations
- Work with teams on remediation

### Phase 2: Selective Enforcement (Week 3-4)
- Enforce critical security policies
- Continue monitoring
- Document exceptions

### Phase 3: Full Enforcement (Week 5+)
- Enable enforcement for all policies
- Implement exception process
- Set up continuous monitoring
EOF
```

### Step 2: Deploy with GitOps

```yaml
# kyverno-policies/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - policies/kubernetes/control-plane/
  - policies/kubernetes/worker-nodes/
  - policies/kubernetes/rbac/
  - policies/kubernetes/pod-security/

patches:
  - target:
      kind: ClusterPolicy
    patch: |-
      - op: replace
        path: /spec/validationFailureAction
        value: audit
```

### Step 3: Set Up Monitoring

```bash
# Deploy Prometheus metrics
kubectl apply -f monitoring/kyverno-metrics.yaml

# Configure alerts
kubectl apply -f monitoring/alerts/
```

## Monitoring and Reporting

### Step 1: Generate Compliance Reports

```bash
# Run compliance report script
./scripts/generate-compliance-report.sh

# View summary
cat reports/compliance-summary.md

# Generate detailed CSV
kubectl get polr -A -o json | jq -r '
  .items[] | 
  [.metadata.namespace, .metadata.name, .summary.pass, .summary.fail, .summary.skip] | 
  @csv
' > compliance-report.csv
```

### Step 2: Set Up Dashboards

```yaml
# grafana-dashboard.json
{
  "dashboard": {
    "title": "CIS EKS Compliance",
    "panels": [
      {
        "title": "Policy Violations by Namespace",
        "targets": [{
          "expr": "sum by (namespace) (kyverno_policy_results_total{result=\"fail\"})"
        }]
      },
      {
        "title": "Compliance Score",
        "targets": [{
          "expr": "100 * sum(kyverno_policy_results_total{result=\"pass\"}) / sum(kyverno_policy_results_total)"
        }]
      }
    ]
  }
}
```

### Step 3: Automated Reporting

```bash
# Create a CronJob for daily reports
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cis-compliance-reporter
spec:
  schedule: "0 8 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: reporter
            image: kyverno/kyverno-cli:latest
            command:
            - /bin/sh
            - -c
            - |
              kubectl get polr -A -o yaml > /reports/daily-compliance.yaml
              # Send to S3, email, etc.
          restartPolicy: OnFailure
EOF
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Policy Not Triggering

```bash
# Check policy is loaded
kubectl get cpol <policy-name> -o yaml

# Verify match conditions
kubectl explain clusterpolicy.spec.rules.match

# Test with explicit resource
kyverno apply <policy> --resource <resource> -v 5
```

#### 2. False Positives

```bash
# Add exceptions for legitimate cases
kubectl apply -f - <<EOF
apiVersion: kyverno.io/v1
kind: PolicyException
metadata:
  name: allow-system-pods
spec:
  exceptions:
  - policyName: cis-5-1-1-image-scanning
    ruleNames:
    - check-image-scanning
  match:
    any:
    - resources:
        namespaces:
        - kube-system
        - kube-public
EOF
```

#### 3. Performance Issues

```bash
# Check Kyverno resource usage
kubectl top pods -n kyverno

# Scale Kyverno if needed
kubectl scale deployment kyverno -n kyverno --replicas=3

# Enable webhook caching
kubectl set env deployment/kyverno -n kyverno WEBHOOK_CACHE=true
```

### Debug Commands

```bash
# Increase log verbosity
kubectl set env deployment/kyverno -n kyverno KYVERNO_LOG_LEVEL=5

# View Kyverno logs
kubectl logs -n kyverno deployment/kyverno -f

# Test policy with debug output
kyverno apply <policy> --resource <resource> -v 10

# Validate policy syntax
kyverno validate <policy>
```

## Best Practices

1. **Start Small**: Begin with a subset of policies in a test environment
2. **Audit First**: Always deploy in audit mode before enforcement
3. **Communicate**: Work with development teams on remediation
4. **Document**: Keep clear records of exceptions and reasons
5. **Automate**: Use CI/CD for policy deployment and updates
6. **Monitor**: Set up comprehensive monitoring and alerting
7. **Review**: Regularly review policy effectiveness and violations

## Next Steps

- Explore [advanced policy customization](../policies/customization.md)
- Learn about [exception handling](../policies/exceptions.md)
- Set up [continuous compliance monitoring](../monitoring/setup.md)
- Join our [community discussions](https://github.com/your-org/cis-eks-kyverno/discussions)

Remember: Security is a journey, not a destination. Start with the basics and gradually increase your compliance posture.