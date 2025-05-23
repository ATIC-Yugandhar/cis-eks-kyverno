# Quick Start Guide

Get up and running with CIS EKS Benchmark compliance validation in under 10 minutes.

## 🚀 5-Minute Setup

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-org/cis-eks-kyverno.git
cd cis-eks-kyverno
```

### Step 2: Run Policy Tests Locally
```bash
# Test all policies (no cluster required)
./scripts/test-all-policies.sh

# Expected output:
# Total test cases: 56
# Passed: 56
# Failed: 0
# Errors: 0
```

### Step 3: Validate Against Sample Resources
```bash
# Test specific control (e.g., Pod Security)
kyverno test tests/kubernetes/custom-5.1.1/

# Test all Kubernetes policies
kyverno test tests/kubernetes/
```

## 🎯 Common Use Cases

### 1. Validate Your Existing Kubernetes Resources

```bash
# Export your resources
kubectl get pods -n your-namespace -o yaml > my-pods.yaml

# Validate against CIS policies
kyverno apply policies/kubernetes/pod-security/ --resource my-pods.yaml
```

### 2. Pre-deployment Validation in CI/CD

```yaml
# Example GitHub Actions workflow
name: CIS Compliance Check
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Kyverno CLI
        run: |
          curl -L https://github.com/kyverno/kyverno/releases/latest/download/kyverno-cli_linux_x86_64.tar.gz | tar -xz
          sudo mv kyverno /usr/local/bin/
      
      - name: Validate Kubernetes manifests
        run: |
          kyverno apply policies/kubernetes/ --resource manifests/
```

### 3. Terraform Plan Validation

```bash
# Initialize and plan your Terraform
cd terraform/your-eks-config
terraform init
terraform plan -out=tfplan.binary

# Convert to JSON
terraform show -json tfplan.binary > tfplan.json

# Validate against CIS policies
export KYVERNO_EXPERIMENTAL=true
kyverno apply policies/terraform/ --resource tfplan.json
```

### 4. Cluster-wide Compliance Scan

```bash
# Install Kyverno in your cluster
kubectl create -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml

# Apply CIS policies in audit mode
kubectl apply -f policies/kubernetes/

# Generate compliance report
kubectl get polr -A -o yaml > compliance-report.yaml
```

## 📊 Understanding Results

### Policy Test Output
```
Loading test ( tests/kubernetes/custom-5.1.1/compliant/kyverno-test.yaml ) ...
│────│─────────────────────────────│──────────────────────│──────────────────────────────│────────│
│ ID │ POLICY                      │ RULE                 │ RESOURCE                     │ RESULT │
│────│─────────────────────────────│──────────────────────│──────────────────────────────│────────│
│ 1  │ custom-5-1-1-image-scanning │ check-image-scanning │ v1/Pod/default/compliant-pod │ Pass   │
│────│─────────────────────────────│──────────────────────│──────────────────────────────│────────│
```

### Policy Validation Results
- **Pass**: Resource complies with the policy
- **Fail**: Resource violates the policy
- **Skip**: Policy doesn't apply to this resource
- **Error**: Policy execution error

## 🏃 Next Steps

### For Development Teams
1. Integrate policies into your CI/CD pipeline
2. Create custom policies for your specific requirements
3. Set up automated compliance reporting

### For Security Teams
1. Deploy policies to production clusters in audit mode
2. Review policy violations and remediation steps
3. Gradually enforce policies after remediation

### For Platform Teams
1. Incorporate policies into cluster provisioning
2. Set up monitoring and alerting for violations
3. Create exception workflows for legitimate deviations

## 🛠️ Quick Commands Reference

```bash
# Test all policies
./scripts/test-all-policies.sh

# Test specific CIS section
kyverno test tests/kubernetes/custom-5.*/

# Validate specific resource type
kyverno apply policies/kubernetes/pod-security/ --resource pods.yaml

# Generate compliance report
./scripts/compliance-report.sh

# Run Terraform validation
./scripts/test-terraform-cis-policies.sh
```

## 🆘 Getting Help

- **Documentation**: See [step-by-step guide](step-by-step.md) for detailed instructions
- **Examples**: Check the `examples/` directory for working configurations
- **Issues**: Report problems at [GitHub Issues](https://github.com/your-org/cis-eks-kyverno/issues)
- **Community**: Join our [Slack channel](#) for discussions

## ⚡ Pro Tips

1. **Start with audit mode** - Don't enforce policies immediately
2. **Test thoroughly** - Use the provided test suites before deployment
3. **Customize carefully** - Some CIS controls may need adjustment for your environment
4. **Monitor continuously** - Set up alerts for policy violations
5. **Document exceptions** - Maintain clear records of approved deviations

Ready for a deeper dive? Check out our [comprehensive step-by-step tutorial](step-by-step.md).