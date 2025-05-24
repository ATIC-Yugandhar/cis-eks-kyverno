# Prerequisites

Before you begin implementing CIS EKS Benchmark compliance with Kyverno, ensure you have the following tools and access configured.

## Required Tools

### 1. Kyverno CLI
The Kyverno CLI is essential for policy testing and validation.

```bash
# Install via Homebrew (macOS)
brew install kyverno

# Install via curl (Linux/macOS)
curl -L https://github.com/kyverno/kyverno/releases/latest/download/kyverno-cli_v1.11.0_linux_x86_64.tar.gz | tar -xz
sudo mv kyverno /usr/local/bin/

# Verify installation
kyverno version
```

### 2. kubectl
Required for Kubernetes cluster interaction.

```bash
# Install via Homebrew (macOS)
brew install kubectl

# Install via curl (Linux)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### 3. Terraform (Optional)
Required only for plan-time validation features.

```bash
# Install via Homebrew (macOS)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install via package manager (Linux)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

### 4. AWS CLI (Optional)
Required for EKS cluster management and AWS resource interaction.

```bash
# Install via Homebrew (macOS)
brew install awscli

# Install via curl (Linux)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation and configure
aws --version
aws configure
```

### 5. Git
Required for cloning the repository and version control.

```bash
# Install via package manager
# macOS
brew install git

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install git

# Verify installation
git --version
```

## System Requirements

- **Operating System**: Linux, macOS, or Windows with WSL2
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Disk Space**: At least 2GB free space
- **Internet Connection**: Required for downloading policies and dependencies

## Access Requirements

### For Runtime Validation
- Access to a Kubernetes cluster (EKS, local Kind/Minikube, or other)
- Cluster admin permissions for policy installation
- kubectl configured with cluster credentials

### For Plan-time Validation
- AWS account with permissions to create EKS clusters
- Terraform state storage configured (S3 bucket recommended)
- IAM permissions for EKS management

### Minimum AWS IAM Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "kms:*",
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Recommended Knowledge

- Basic understanding of Kubernetes concepts (pods, services, RBAC)
- Familiarity with YAML syntax
- Basic command-line skills
- Understanding of security best practices

## Environment Setup Verification

Run this script to verify your environment is properly configured:

```bash
#!/bin/bash
echo "Checking prerequisites..."

# Check Kyverno CLI
if command -v kyverno &> /dev/null; then
    echo "✅ Kyverno CLI: $(kyverno version 2>&1 | grep Version)"
else
    echo "❌ Kyverno CLI: Not found"
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl: $(kubectl version --client --short 2>&1)"
else
    echo "❌ kubectl: Not found"
fi

# Check Terraform
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform version | head -n 1)"
else
    echo "⚠️  Terraform: Not found (optional)"
fi

# Check AWS CLI
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI: $(aws --version)"
else
    echo "⚠️  AWS CLI: Not found (optional)"
fi

# Check Git
if command -v git &> /dev/null; then
    echo "✅ Git: $(git --version)"
else
    echo "❌ Git: Not found"
fi

# Check kubectl cluster connection
if kubectl cluster-info &> /dev/null; then
    echo "✅ Kubernetes cluster: Connected"
else
    echo "⚠️  Kubernetes cluster: Not connected (optional for policy testing)"
fi
```

## Next Steps

Once you have all prerequisites installed and configured:

1. Clone the repository
2. Review the [Quick Start Guide](quick-start.md)
3. Follow the [Step-by-Step Tutorial](step-by-step.md)

## Troubleshooting

### Common Issues

**Kyverno CLI not found after installation**
- Ensure `/usr/local/bin` is in your PATH
- Run `export PATH=$PATH:/usr/local/bin`
- Add to your shell profile for persistence

**kubectl cannot connect to cluster**
- Verify cluster is running: `kubectl cluster-info`
- Check kubeconfig: `echo $KUBECONFIG`
- Ensure credentials are valid: `aws eks update-kubeconfig --name <cluster-name>`

**Permission denied errors**
- Ensure you have cluster admin permissions
- Check IAM roles and policies for AWS resources
- Verify RBAC permissions in Kubernetes

For additional help, see our [troubleshooting guide](../troubleshooting.md) or open an issue on GitHub.