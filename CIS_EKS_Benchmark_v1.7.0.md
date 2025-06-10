# 📘 CIS Amazon EKS Benchmark v1.7.0  
**All Controls by Section**  
*Total: 46 controls*

---

## ✅ Section 1 - Control Plane Components  
*No controls – informational only*

---

## 🛠️ Section 2 - Control Plane Configuration  

### 🔍 2.1 Logging  
- **2.1.1** Enable audit logs  
- **2.1.2** Ensure audit logs are collected and managed  

---

## 🧱 Section 3 - Worker Nodes  

### 📄 3.1 Worker Node Configuration Files  
- **3.1.1** Ensure that the kubeconfig file permissions are set to 644 or more restrictive  
- **3.1.2** Ensure that the kubelet kubeconfig file ownership is set to root:root  
- **3.1.3** Ensure that the kubelet configuration file has permissions set to 644 or more restrictive  
- **3.1.4** Ensure that the kubelet configuration file ownership is set to root:root  

### ⚙️ 3.2 Kubelet  
- **3.2.1** Ensure that the Anonymous Auth is not enabled  
- **3.2.2** Ensure that the `--authorization-mode` argument is not set to `AlwaysAllow`  
- **3.2.3** Ensure that a Client CA File is configured  
- **3.2.4** Ensure that the `--read-only-port` is disabled  
- **3.2.5** Ensure that the `--streaming-connection-idle-timeout` argument is not set to 0  
- **3.2.6** Ensure that the `--make-iptables-util-chains` argument is set to `true`  
- **3.2.7** Ensure that the `--eventRecordQPS` argument is set to 0 or an appropriate value  
- **3.2.8** Ensure that the `--rotate-certificates` argument is not present or is set to `true`  
- **3.2.9** Ensure that the `RotateKubeletServerCertificate` argument is set to `true`  

---

## 🔐 Section 4 - Policies  

### 🧾 4.1 RBAC and Service Accounts  
- **4.1.1** Ensure that the cluster-admin role is only used where required  
- **4.1.2** Minimize access to secrets  
- **4.1.3** Minimize wildcard use in Roles and ClusterRoles  
- **4.1.4** Minimize access to create pods  
- **4.1.5** Ensure that default service accounts are not actively used  
- **4.1.6** Ensure that Service Account Tokens are only mounted where necessary  
- **4.1.7** Use Cluster Access Manager API to streamline access control management  
- **4.1.8** Limit use of the `Bind`, `Impersonate`, and `Escalate` permissions  

### 🛡️ 4.2 Pod Security Standards  
- **4.2.1** Minimize the admission of privileged containers  
- **4.2.2** Minimize the admission of containers sharing host PID namespace  
- **4.2.3** Minimize the admission of containers sharing host IPC namespace  
- **4.2.4** Minimize the admission of containers sharing host network namespace  
- **4.2.5** Minimize the admission of containers with `allowPrivilegeEscalation`  

### 🌐 4.3 CNI Plugin  
- **4.3.1** Ensure CNI plugin supports NetworkPolicies  
- **4.3.2** Ensure all namespaces have NetworkPolicies defined  

### 🔑 4.4 Secrets Management  
- **4.4.1** Prefer using secrets as files over environment variables  
- **4.4.2** Consider external secret storage  

### 📦 4.5 General Policies  
- **4.5.1** Create administrative boundaries between resources using namespaces  
- **4.5.2** Avoid using the default namespace  

---

## 🧩 Section 5 - Managed Services  

### 🖼️ 5.1 Image Registry and Scanning  
- **5.1.1** Ensure image vulnerability scanning via Amazon ECR or third-party tool  
- **5.1.2** Minimize user access to Amazon ECR  
- **5.1.3** Minimize cluster access to Amazon ECR (read-only)  
- **5.1.4** Limit container registries to approved sources  

### 🔐 5.2 IAM  
- **5.2.1** Prefer dedicated EKS service accounts  

### 🔐 5.3 AWS KMS  
- **5.3.1** Encrypt Kubernetes secrets using CMKs managed in AWS KMS  

### 🌐 5.4 Cluster Networking  
- **5.4.1** Restrict access to the control plane endpoint  
- **5.4.2** Enable private endpoint; disable public access  
- **5.4.3** Deploy clusters with private nodes  
- **5.4.4** Enable and configure network policies appropriately  
- **5.4.5** Encrypt traffic to HTTPS load balancers with TLS  

### 👥 5.5 AuthN & AuthZ  
- **5.5.1** Use IAM Authenticator or AWS CLI v1.16.156+ for RBAC management  
