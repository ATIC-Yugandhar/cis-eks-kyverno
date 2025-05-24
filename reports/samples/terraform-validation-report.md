# Final Report: EKS CIS Benchmark Validation with Kyverno JSON Policies

## Overview

This report summarizes the validation of Amazon EKS clusters against the CIS Benchmark using Kyverno JSON policies at the Terraform plan level. Both compliant and noncompliant cluster architectures were tested to evaluate policy effectiveness and automation workflows.

---

## Automated Plan-Level Policy Validation

- All enforceable CIS controls are validated at the Terraform plan stage using Kyverno JSON policies (`kyverno-json`).
- Policies are located in `kyverno-policies/terraform/` and are written in the `json.kyverno.io/v1alpha1` format.
- The script `./scripts/test-terraform-cis-policies.sh` automates plan generation, policy scanning, and report creation for both compliant and noncompliant stacks.
- Results are written to `reports/compliance/` as YAML files for each stack.

### Usage
```bash
./scripts/test-terraform-cis-policies.sh
```

---

## Testing Workflows

### Plan-Level Testing (Automated)

- Terraform plans are generated for both the compliant and noncompliant EKS stacks.
- Kyverno JSON policies are run against the plan JSONs to validate CIS controls before any resources are applied.
- Reports show which controls are passed or failed at the plan stage.

---

## Cluster Architectures

### Compliant Cluster

- **Private Networking:** All nodes and control plane endpoints are private, inaccessible from the public internet.
- **KMS Encryption:** Kubernetes secrets are encrypted at rest (config block present in plan).
- **Network Policies:** Enforced to restrict pod-to-pod and pod-to-external communications.
- **Audit Logging:** Enabled in the EKS cluster config.

### Noncompliant Cluster

- **Public Endpoints:** Nodes and/or control plane are accessible from the public internet.
- **No Encryption:** Secrets are stored unencrypted (no config block in plan).
- **Open Network:** Network policies are absent or permissive.
- **No Audit Logging:** Audit logging is disabled.

---

## Plan-Time vs Runtime Enforcement

- **Plan-Time:** Kyverno JSON policies can only validate what is present in the Terraform plan. Some values (e.g., computed ARNs, runtime IAM state) are not available until after apply.
- **Runtime:** Some CIS controls require AWS-side or runtime validation. See `docs/UNENFORCEABLE_CONTROLS.md` for details.
- Policies are written to check for configuration presence where possible, but full enforcement may require post-apply or AWS-side validation.

---

## Automation Scripts

- **scripts/test-terraform-cis-policies.sh:** Automates plan generation, policy scanning, and report creation for both stacks.
- **scripts/cleanup.sh:** Cleans up generated files and plans.

### Usage

```bash
# Run plan-level policy validation
./scripts/test-terraform-cis-policies.sh

# Cleanup generated files
./scripts/cleanup.sh
```

---

## Known Limitations

- Some CIS controls require AWS-side enforcement or are only partially enforceable at the plan level (see `docs/UNENFORCEABLE_CONTROLS.md`).
- Plan-time validation is limited to what is present in the Terraform plan JSON.

---

## Conclusion

Kyverno JSON policies were validated in both compliant and noncompliant EKS plan scenarios. The compliant architecture passes all enforceable CIS controls at the plan stage, while the noncompliant setup demonstrates policy violations. Automation scripts streamline the validation process and generate auditable compliance reports.