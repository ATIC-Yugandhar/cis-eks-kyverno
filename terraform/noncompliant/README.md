# CIS Noncompliant EKS Automation (Noncompliant Cluster)

**This stack provisions an intentionally noncompliant EKS cluster to serve as a negative test case for plan-level Kyverno JSON policy validation.**

- Automated validation is performed using `scripts/test-terraform-policies.sh`.
- See `policies/terraform/README.md` for policy details and plan-time limitations.

## Prerequisites

- [Kyverno CLI must be installed](https://kyverno.io/docs/installation/) locally and/or in your Kubernetes cluster.

## Noncompliant Aspects
This stack is configured to violate key CIS EKS controls, including:

- EKS API endpoint is public (`endpoint_public_access = true`, `endpoint_private_access = false`)
- No audit logging enabled
- No secrets encryption (no `encryption_config` block)
- Node groups are placed in public subnets
- No Kubernetes network policies present

## Purpose
This stack is used to demonstrate that Kyverno JSON policies can detect and fail noncompliant infrastructure at the Terraform plan stage.

---

**This stack should fail all relevant CIS policies when scanned at plan time.** 