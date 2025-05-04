# Unsupported CIS Controls (Not Enforceable by Kyverno)

| CIS ID  | Description                                               | Rationale                        |
|---------|-----------------------------------------------------------|-----------------------------------|
| 2.1.1   | Enable audit logs                                         | Not enforceable by Kyverno        |
| 2.1.2   | Ensure audit logs are collected and managed               | Not enforceable by Kyverno        |
| 3.1.1   | kubeconfig file permissions set to 644 or more restrictive| Not enforceable by Kyverno        |
| 3.1.2   | kubelet kubeconfig file owned by root:root                | Not enforceable by Kyverno        |
| 3.1.3   | kubelet config file permissions set to 644 or more restrictive | Not enforceable by Kyverno   |
| 3.1.4   | kubelet config file owned by root:root                    | Not enforceable by Kyverno        |
| 3.2.3   | Client CA file configured                                 | Not enforceable by Kyverno        |
| 3.2.4   | --read-only-port is disabled                              | Not enforceable by Kyverno        |
| 3.2.5   | --streaming-connection-idle-timeout not set to 0          | Not enforceable by Kyverno        |
| 3.2.6   | --make-iptables-util-chains set to true                   | Not enforceable by Kyverno        |
| 3.2.7   | --eventRecordQPS set appropriately or to 0                | Not enforceable by Kyverno        |
| 3.2.8   | --rotate-certificates is true or absent                   | Not enforceable by Kyverno        |
| 3.2.9   | RotateKubeletServerCertificate is true                    | Not enforceable by Kyverno        |
| 4.1.7   | Use Cluster Access Manager API                            | Not enforceable by Kyverno        |
| 4.3.1   | Ensure CNI plugin supports network policies               | Not enforceable by Kyverno        |
| 4.4.2   | Use external secret storage                               | Not enforceable by Kyverno        |
| 5.1.1   | Enable image scanning in ECR or third-party               | Not enforceable by Kyverno        |
| 5.1.2   | Minimize user access to ECR                               | Not enforceable by Kyverno        |
| 5.1.3   | Limit cluster ECR access to read-only                     | Not enforceable by Kyverno        |
| 5.3.1   | Encrypt Kubernetes Secrets with KMS CMKs                  | Not enforceable by Kyverno        |
| 5.4.1   | Restrict control plane endpoint access                    | Not enforceable by Kyverno        |
| 5.4.2   | Use private endpoint, disable public access               | Not enforceable by Kyverno        |
| 5.4.3   | Deploy private nodes                                      | Not enforceable by Kyverno        |
| 5.4.5   | Use TLS to encrypt load balancer traffic                  | Not enforceable by Kyverno        |
| 5.5.1   | Manage users via IAM Authenticator or AWS CLI             | Not enforceable by Kyverno        |