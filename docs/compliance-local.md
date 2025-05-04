# Local Kyverno Validation
```
Validating policy: kyverno-policies/cis-2.1.1-enable-audit-logs.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-2.1.2-ensure-audit-logs-are-collected-and-managed.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.1.1-kubeconfig-file-permissions-set-to-644-or-more-restrictive.yaml

Applying 0 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-3.1.1-kubeconfig-file-permissions-set-to-644-or-more-restrictive
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

Validating policy: kyverno-policies/cis-3.1.2-kubelet-kubeconfig-file-owned-by-root-root.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.1.3-kubelet-config-file-permissions-set-to-644-or-more-restrictive.yaml

Applying 0 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-3.1.3-kubelet-config-file-permissions-set-to-644-or-more-restrictive
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

Validating policy: kyverno-policies/cis-3.1.4-kubelet-config-file-owned-by-root-root.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.3-client-ca-file-configured.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.4--read-only-port-is-disabled.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.5--streaming-connection-idle-timeout-not-set-to-0.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.6--make-iptables-util-chains-set-to-true.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.7--eventrecordqps-set-appropriately-or-to-0.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.8--rotate-certificates-is-true-or-absent.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-3.2.9-rotatekubeletservercertificate-is-true.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.1.1.yaml

Applying 1 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-4.1.1
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

Validating policy: kyverno-policies/cis-4.1.2.yaml

Applying 1 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-4.1.2
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

Validating policy: kyverno-policies/cis-4.1.3.yaml

Applying 1 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-4.1.3
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

Validating policy: kyverno-policies/cis-4.1.4.yaml

Applying 1 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-4.1.4
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

Validating policy: kyverno-policies/cis-4.1.5-default-service-accounts-should-not-be-used.yaml

Applying 3 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.1.6-mount-service-account-tokens-only-when-necessary.yaml

Applying 4 policy rule(s) to 3 resource(s)...
policy cis-4.1.6-mount-service-account-tokens-only-when-necessary -> resource sample-namespace/Deployment/sample-deployment failed:
1 - autogen-restrict-pod-automountServiceAccountToken validation error: Pod spec.automountServiceAccountToken must be set to false unless explicitly needed. rule autogen-restrict-pod-automountServiceAccountToken failed at path /spec/template/spec/automountServiceAccountToken/


pass: 1, fail: 1, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.1.7-use-cluster-access-manager-api.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.2.1-minimize-privileged-containers.yaml

Applying 3 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.2.2-minimize-host-pid-namespace-sharing.yaml

Applying 3 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.2.3-minimize-host-ipc-namespace-sharing.yaml

Applying 3 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.2.4-minimize-host-network-namespace-sharing.yaml

Applying 3 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.2.5-disallow-allowprivilegeescalation.yaml

Applying 3 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.3.1-ensure-cni-plugin-supports-network-policies.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.3.2-ensure-all-namespaces-have-network-policies.yaml

Applying 1 policy rule(s) to 3 resource(s)...
policy cis-4.3.2-ensure-all-namespaces-have-network-policies -> resource default/Namespace/sample-namespace failed:
1 - require-ns-networkpolicy-label validation error: Namespace must have a 'network-policy/status=applied' label to indicate NetworkPolicies are configured. rule require-ns-networkpolicy-label failed at path /metadata/labels/


pass: 0, fail: 1, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.4.1-use-secrets-as-files-not-environment-variables.yaml

Applying 6 policy rule(s) to 3 resource(s)...

pass: 2, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.4.2-use-external-secret-storage.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.5.1-use-namespaces-for-resource-boundaries.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-4.5.2-avoid-using-the-default-namespace.yaml

Applying 1 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.1.1-enable-image-scanning-in-ecr-or-third-party.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.1.2-minimize-user-access-to-ecr.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.1.3-limit-cluster-ecr-access-to-read-only.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.1.4-restrict-use-to-approved-container-registries.yaml

Applying 3 policy rule(s) to 3 resource(s)...
policy cis-5.1.4-restrict-use-to-approved-container-registries -> resource sample-namespace/Deployment/sample-deployment failed:
1 - autogen-validate-registries validation error: Images must be from approved registries (your-registry.com, another-registry.com). rule autogen-validate-registries failed at path /spec/template/spec/containers/0/image/


pass: 0, fail: 1, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.2.1-use-dedicated-eks-service-accounts.yaml

Applying 1 policy rule(s) to 3 resource(s)...

pass: 1, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.3.1-encrypt-kubernetes-secrets-with-kms-cmks.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.4.1-restrict-control-plane-endpoint-access.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.4.2-use-private-endpoint-disable-public-access.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.4.3-deploy-private-nodes.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.4.4-enable-and-configure-network-policy.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.4.5-use-tls-to-encrypt-load-balancer-traffic.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/cis-5.5.1-manage-users-via-iam-authenticator-or-aws-cli.yaml

Applying 0 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/custom-3.2.1.yaml

Applying 1 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/custom-3.2.2.yaml

Applying 1 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/custom-4.1.8.yaml

Applying 1 policy rule(s) to 3 resource(s)...

pass: 0, fail: 0, warn: 0, error: 0, skip: 0 

Validating policy: kyverno-policies/custom-4.5.1.yaml

Applying 1 policy rule(s) to 3 resource(s)...
----------------------------------------------------------------------
Policies Skipped (as required variables are not provided by the user):
1. cis-4-5-1-use-namespaces-for-boundaries
----------------------------------------------------------------------

pass: 0, fail: 0, warn: 0, error: 1, skip: 0 

```
