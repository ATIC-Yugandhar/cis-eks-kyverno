# Examples

This directory contains complete, working examples demonstrating different use cases and complexity levels.

## Available Examples

### [Basic Setup](basic-setup/)
Simple example perfect for getting started:
- Minimal EKS cluster configuration
- Essential security policies
- Basic compliance validation
- Step-by-step walkthrough

### [Production Ready](production-ready/)
Advanced example suitable for production environments:
- Comprehensive EKS cluster with all security features
- Complete policy suite covering all CIS controls
- Advanced monitoring and logging
- Multi-environment support

### [Custom Scenarios](custom-scenarios/)
Additional examples for specific use cases:
- Industry-specific compliance requirements
- Integration with existing infrastructure
- Custom policy development
- Advanced testing scenarios

## Example Structure

Each example includes:
```
example-name/
├── README.md              # Complete walkthrough
├── terraform/             # Infrastructure code
├── policies/              # Relevant policies
├── tests/                 # Test configurations
└── scripts/               # Automation scripts
```

## Usage

1. Choose the example that best fits your needs
2. Follow the README.md in each example directory
3. Adapt the configurations to your environment
4. Run the provided scripts for automation

## Prerequisites

- AWS CLI configured
- Terraform installed
- Kyverno CLI installed
- kubectl configured