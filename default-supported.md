# Default-Supported CIS Controls (Kyverno)

| CIS ID  | Description                                         | Policy Filename                   |
|---------|-----------------------------------------------------|-----------------------------------|
| 4.1.1   | Use cluster-admin role only when required           | kyverno-policies/cis-4.1.1.yaml   |
| 4.1.2   | Minimize access to secrets                          | kyverno-policies/cis-4.1.2.yaml   |
| 4.1.3   | Minimize wildcard use in roles                      | kyverno-policies/cis-4.1.3.yaml   |
| 4.1.4   | Minimize access to create pods                      | kyverno-policies/cis-4.1.4.yaml   |
| 4.1.5   | Default service accounts should not be used         |                                   |
| 4.1.6   | Mount service account tokens only when necessary    |                                   |
| 4.2.1   | Minimize privileged containers                      |                                   |
| 4.2.2   | Minimize host PID namespace sharing                 |                                   |
| 4.2.3   | Minimize host IPC namespace sharing                 |                                   |
| 4.2.4   | Minimize host network namespace sharing             |                                   |
| 4.2.5   | Disallow allowPrivilegeEscalation                   |                                   |
| 4.3.2   | Ensure all Namespaces have Network Policies         |                                   |
| 4.4.1   | Use secrets as files, not environment variables     |                                   |
| 4.5.2   | Avoid using the default namespace                   |                                   |
| 5.1.4   | Restrict use to approved container registries       |                                   |
| 5.2.1   | Use dedicated EKS Service Accounts                  |                                   |
| 5.4.4   | Enable and configure Network Policy                 |                                   |