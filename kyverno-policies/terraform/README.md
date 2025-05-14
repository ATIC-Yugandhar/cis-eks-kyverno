# Kyverno JSON Policies for Terraform

This folder contains Kyverno policies written in the `json.kyverno.io/v1alpha1` format, designed to validate Terraform plan JSON files using `kyverno-json`.

- Use these policies with the `kyverno-json` CLI.
- Policies here are tailored for IaC (Terraform) security and compliance checks, specifically for CIS EKS Benchmark controls that can be enforced at the Terraform plan level.
- The policies are used in an automated workflow (see `scripts/test-terraform-cis-policies.sh`) to validate both compliant and noncompliant EKS clusters.

## Prerequisites

- [Kyverno CLI must be installed](https://kyverno.io/docs/installation/) locally and/or in your Kubernetes cluster.

## Limitations

- Some CIS controls (e.g., KMS encryption for secrets) rely on values that are only known after `terraform apply` (such as computed ARNs). In these cases, policies check for the presence of the configuration block (e.g., `encryption_config` for secrets) rather than the actual resolved value.
- This is a limitation of static Terraform plan analysis and applies to any tool that scans plans before apply.

## Example Usage

```sh
kyverno-json scan --payload <tfplan.json> --policy kyverno-policies/terraform/
```

## Contributing

To add a new policy, create a new YAML file in this folder using the `json.kyverno.io/v1alpha1` ValidatingPolicy format. Test your policy using the provided test script and sample plans. 