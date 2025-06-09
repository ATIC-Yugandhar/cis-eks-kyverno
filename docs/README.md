# Documentation

This directory contains official documentation and compliance benchmarks for the CIS EKS Kyverno Compliance Framework.

## 📚 Available Documentation

### Compliance Standards
- **CIS_Amazon_Elastic_Kubernetes_Service_(EKS)_Benchmark_v1.7.0_PDF.pdf** - Official CIS EKS Benchmark v1.7.0 specification

### Visual Documentation
- **images/** - Diagrams and screenshots supporting the documentation

## 🚀 Getting Started

- Review [policy structure](../policies/README.md) for implementation details
- Check [test framework](../tests/README.md) for comprehensive test scenarios
- Use [automation scripts](../scripts/README.md) for testing and validation
- Explore [compliant configurations](../opentofu/compliant/) for production examples
- Review [non-compliant configurations](../opentofu/noncompliant/) for testing scenarios

## 🏗️ Framework Components

- **Policies**: 62 Kyverno policies organized by CIS control sections
- **Tests**: 62 test scenarios for comprehensive validation
- **Scripts**: 5 automation tools for testing and reporting
- **OpenTofu**: Example configurations for compliant and non-compliant clusters
- **Kube-bench**: CIS node-level compliance scanning integration

## 📋 CIS EKS Benchmark Reference

The included CIS benchmark PDF serves as the authoritative reference for:
- Control definitions and requirements
- Scoring methodology
- Remediation procedures
- Compliance assessment criteria

This framework implements automated validation for the majority of applicable CIS EKS controls using Kyverno policies and kube-bench scanning.