# 📘 CIS Amazon EKS Benchmark Alignment (v1.7.0)

> **Disclaimer:**  
> This repository references the *CIS Amazon EKS Benchmark v1.7.0* for educational and alignment purposes only.  
> No CIS Benchmark content is reproduced here.  
> For full and official benchmark details, please visit the [CIS SecureSuite website](https://www.cisecurity.org/cis-securesuite) or contact CIS Legal at [legalnotices@cisecurity.org](mailto:legalnotices@cisecurity.org).  

*This document summarizes high-level security controls inspired by the CIS EKS Benchmark to help demonstrate compliance automation using Kyverno and other CNCF tools.*

---

## ✅ Section 1 – Control Plane Components  
Informational only; no actionable security controls are defined in this section.

---

## 🛠️ Section 2 – Control Plane Configuration  

### 🔍 Logging  
- **2.1.1** Validate that cluster audit logging is enabled and functional.  
- **2.1.2** Confirm that audit logs are centrally collected and monitored.

---

## 🧱 Section 3 – Worker Nodes  

### 📄 Worker Node Configuration Files  
- **3.1.1–3.1.4** Validate secure permissions and ownership for `kubeconfig` and kubelet configuration files to prevent unauthorized modification or access.

### ⚙️ Kubelet Security  
- **3.2.1–3.2.9** Apply secure kubelet settings such as disabling anonymous access, enforcing authorization modes, enabling certificate rotation, and restricting read-only ports.

---

## 🔐 Section 4 – Kubernetes Policies  

### 🧾 RBAC and Service Accounts  
- **4.1.x** Apply the principle of least privilege by limiting admin-level roles, controlling secret access, and restricting wildcard permissions.  
- Enforce separation of duties and avoid using default service accounts in production namespaces.

### 🛡️ Pod Security Standards  
- **4.2.x** Prevent the admission of privileged or host-namespace containers and enforce least-privilege runtime configurations.

### 🌐 CNI & Network Policies  
- **4.3.x** Use CNI plugins that support Kubernetes NetworkPolicies and ensure every namespace defines network restrictions.

### 🔑 Secrets Management  
- **4.4.x** Prefer file-based secrets over environment variables and consider integrating with external secret managers such as AWS Secrets Manager or HashiCorp Vault.

### 📦 Namespace & Resource Policies  
- **4.5.x** Create administrative boundaries between namespaces and avoid deploying workloads in the default namespace.

---

## 🧩 Section 5 – Managed Services and Integrations  

### 🖼️ Image Registry and Scanning  
- **5.1.x** Use trusted image registries, enable image vulnerability scanning, and enforce least-privilege access to Amazon ECR.

### 🔐 Identity & Access Management  
- **5.2.x** Use dedicated EKS service accounts with appropriate IAM roles.  
- **5.3.x** Encrypt secrets using AWS KMS Customer Managed Keys (CMKs).

### 🌐 Cluster Networking  
- **5.4.x** Restrict API endpoint access, use private networking for nodes, enforce TLS encryption, and define Kubernetes NetworkPolicies.

### 👥 Authentication & Authorization  
- **5.5.x** Manage cluster access through AWS IAM authenticator or AWS CLI, ensuring that RBAC mappings are auditable and consistent.

---

## ⚖️ License & Attribution  
This repository is **not affiliated with or endorsed by CIS**.  
CIS® and the CIS Benchmarks™ are trademarks of the Center for Internet Security, Inc.  
Official benchmarks are available exclusively to CIS members via [CIS SecureSuite](https://www.cisecurity.org/cis-securesuite).
