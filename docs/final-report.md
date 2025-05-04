# CIS EKS Kyverno Coverage Final Report

## Overview

This report summarizes the coverage of CIS Amazon EKS Benchmark controls using Kyverno policies.

---

### Total Number of CIS Controls

**46**

---

### Coverage by Category

| Category            | Count | Percentage |
|---------------------|-------|------------|
| Default-Supported   | 17    | 36.96%     |
| Custom-Required     | 4     | 8.70%      |
| Unsupported         | 25    | 54.35%     |

- **Default-Supported**: Controls with direct Kyverno policy support (✅)
- **Custom-Required**: Controls with partial support or requiring custom logic (⚠️ Partial)
- **Unsupported**: Controls not addressable by Kyverno (❌)

---

### Policy Coverage Percentage

**Supported (Default + Custom):**  
21 / 46 = **45.65%**

---

### Key Insights

#### Major Coverage Gaps
- Over half of CIS controls (54.35%) are not enforceable via Kyverno, mainly due to requirements outside Kubernetes policy scope (e.g., audit log configuration, ECR settings, node/infra controls).
- Controls related to cluster configuration, AWS-specific settings, and external integrations are typically unsupported.

#### Enforcement Highlights
- All supported controls are enforced via Kyverno's `validate` action.
- Partial support (custom-required) often involves audit-only policies or external validation (e.g., for authorization modes, namespace boundaries, or permissions escalation).

#### Notable Implementation Notes
- Some controls marked as "Partial" require manual review or external audit tools in addition to Kyverno policies.
- Policy coverage is strongest in areas related to RBAC, namespace isolation, service account usage, and container security.
- For unsupported controls, alternative mechanisms (AWS config, manual checks, or other tools) are necessary.

---

### Summary Table

| CIS Control | Description | Kyverno Supported | Action/Note         |
|-------------|-------------|-------------------|---------------------|
| ...         | ...         | ...               | ...                 |

(See mapping.xlsx for the full mapping.)

---