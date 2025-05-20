# CIS EKS Kyverno Compliance Framework

A robust, auditable framework for implementing and validating CIS Amazon EKS Benchmark controls using Kyverno policies and Terraform. The repo enables automated deployment, testing, and reporting for both compliant and noncompliant EKS clusters.

---

## Key Features

- **CIS-Compliant and Noncompliant EKS Deployments:** Automated Terraform stacks for both secure (compliant) and intentionally insecure (noncompliant) EKS clusters.
- **Policy-as-Code:** Kyverno policies mapped to CIS controls, with test cases for each.
- **Automated Validation:** Scripts to deploy clusters, generate Terraform JSON plans, and scan them with Kyverno.
- **Test Framework:** Organized test cases for each CIS control, with expected pass/fail results.
- **Cleanup Automation:** Scripted teardown of all resources.
- **Separation of Concerns:** All sensitive operations and validation are performed inside the VPC for compliance.

---

## Repository Structure

```
.
├── terraform/           # Infrastructure as code (compliant & noncompliant)
├── kyverno-policies/    # Kyverno policies for CIS controls
├── tests/               # Kyverno test cases for each control
├── scripts/             # Automation scripts (deploy, validate, cleanup)
├── reports/             # Generated compliance reports
└── README.md            # This file
```

---

## Quick Start

1. **Deploy a Compliant Cluster and Validate:**
   ```bash
   bash scripts/compliant-validate.sh
   ```
   - Deploys the compliant stack, generates a Terraform plan, and scans it with all Kyverno policies.

2. **Deploy a Noncompliant Cluster and Validate:**
   ```bash
   bash scripts/noncompliant-validate.sh
   ```

3. **Cleanup All Resources:**
   ```bash
   bash scripts/cleanup.sh
   ```

---

## Requirements

- Terraform v1.0+
- AWS CLI v2
- Kyverno CLI ([installation guide](https://kyverno.io/docs/installation/))
- Python 3.8+

**Prerequisite:** Kyverno must be installed in your Kubernetes cluster and/or locally for CLI usage. See the [Kyverno installation documentation](https://kyverno.io/docs/installation/) for instructions.

---

## How It Works

- **Terraform** provisions EKS clusters (compliant and noncompliant) with all required AWS resources.
- **Kyverno policies** are applied to the generated Terraform JSON plan to validate compliance.
- **Test cases** in `tests/` provide resource manifests and expected results for each CIS control.
- **Reports** are generated in `reports/compliance/` for both cluster types.

---

## Folder Overview

- **terraform/**: Infrastructure as code for compliant and noncompliant EKS clusters.
- **kyverno-policies/**: Kyverno policies mapped to CIS EKS Benchmark controls.
- **tests/**: Kyverno test cases for each CIS control, with compliant and noncompliant scenarios.
- **scripts/**: Automation scripts for deployment, validation, and cleanup.
- **reports/**: Generated compliance reports from Kyverno scans.

---

## Contributing

Contributions are welcome! Please feel free to submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
