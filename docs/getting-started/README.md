# Getting Started

Welcome to the CIS EKS Kyverno Compliance Framework! This section will help you get up and running quickly.

## 📚 Documentation Structure

### [Prerequisites](prerequisites.md)
Start here to ensure your environment is properly configured with all required tools and access.

### [Quick Start Guide](quick-start.md)
Get up and running in under 10 minutes with our fast-track guide. Perfect for experienced users who want to jump right in.

### [Step-by-Step Tutorial](step-by-step.md)
A comprehensive walkthrough covering everything from basic setup to production deployment. Recommended for first-time users.

## 🎯 Choose Your Path

### "I want to test policies locally"
➡️ Start with the [Quick Start Guide](quick-start.md) and run the test suite

### "I need to validate my Terraform plans"
➡️ Check [Prerequisites](prerequisites.md) then jump to the Terraform section in [Step-by-Step](step-by-step.md#terraform-plan-time-validation)

### "I'm deploying to production"
➡️ Review all three guides, then focus on [Production Deployment](step-by-step.md#production-deployment)

### "I just want to understand how it works"
➡️ Read through the [Step-by-Step Tutorial](step-by-step.md) which explains all concepts

## 🚀 Quick Commands

```bash
# Clone the repository
git clone https://github.com/your-org/cis-eks-kyverno.git
cd cis-eks-kyverno

# Run all tests
./scripts/test-all-policies.sh

# Check prerequisites
./scripts/check-prerequisites.sh
```

## 💡 Tips for Success

1. **Start with the test suite** - Familiarize yourself with the policies by running tests
2. **Use audit mode** - Don't enforce policies immediately in production
3. **Test incrementally** - Validate policies against your resources before deployment
4. **Monitor continuously** - Set up proper monitoring before enforcing policies
5. **Document exceptions** - Keep track of any policy exceptions you need

## 🆘 Need Help?

- 📖 Check our [troubleshooting guide](../troubleshooting.md)
- 💬 Join the [community discussions](https://github.com/your-org/cis-eks-kyverno/discussions)
- 🐛 Report issues on [GitHub](https://github.com/your-org/cis-eks-kyverno/issues)

## What's Next?

After completing the getting started guides, explore:

- [Architecture Overview](../architecture/) - Understand the framework design
- [Policy Documentation](../policies/) - Deep dive into each CIS control
- [Examples](../../examples/) - Real-world implementation scenarios
- [Contributing](../contributing/) - Help improve the framework

---

Remember: The goal is not just compliance, but improving your overall security posture. Take your time to understand each control and how it applies to your environment.