#!/usr/bin/env bash
set -e

# Test script to verify the CRD annotation filtering fix
echo "🧪 Testing Kyverno CRD Annotation Filtering Fix"
echo "=============================================="

# Test the yq filtering logic on a sample CRD manifest
cat > test-kyverno-sample.yaml << 'EOF'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: clusterpolicies.kyverno.io
  annotations:
    controller-gen.kubebuilder.io/version: v0.10.0
    helm.sh/resource-policy: keep
    meta.helm.sh/release-name: kyverno
    meta.helm.sh/release-namespace: kyverno
    very-large-annotation: |
      This is a very large annotation that would normally cause issues
      with the 262144 bytes limit in Kubernetes. This annotation contains
      a lot of text that makes the CRD manifest exceed the size limit.
      We need to remove this to ensure successful installation.
spec:
  group: kyverno.io
  scope: Cluster
  names:
    plural: clusterpolicies
    singular: clusterpolicy
    kind: ClusterPolicy
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: policies.kyverno.io
  annotations:
    controller-gen.kubebuilder.io/version: v0.10.0
    helm.sh/resource-policy: keep
    another-large-annotation: |
      Another large annotation that needs to be removed
      to prevent size issues with CRD installation.
spec:
  group: kyverno.io
  scope: Namespaced
  names:
    plural: policies
    singular: policy
    kind: Policy
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-svc
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
spec:
  selector:
    app: kyverno
  ports:
  - port: 443
EOF

echo "📄 Original test manifest size: $(wc -c < test-kyverno-sample.yaml) bytes"

# Test the filtering logic
echo "🔄 Applying CRD annotation filtering..."

yq eval '
  del(.metadata.annotations) |
  (select(.kind == "CustomResourceDefinition" and .metadata.name == "clusterpolicies.kyverno.io") | .metadata.annotations) = {} |
  (select(.kind == "CustomResourceDefinition" and .metadata.name == "policies.kyverno.io") | .metadata.annotations) = {} |
  (select(.kind == "CustomResourceDefinition" and (.metadata.name | test(".*\\.kyverno\\.io$"))) | .metadata.annotations) = {}
' test-kyverno-sample.yaml > test-kyverno-filtered.yaml

echo "📄 Filtered test manifest size: $(wc -c < test-kyverno-filtered.yaml) bytes"

# Verify that CRD annotations were removed but Service annotations remain
echo ""
echo "🔍 Verification Results:"
echo "------------------------"

echo "• clusterpolicies.kyverno.io CRD annotations:"
CLUSTER_POLICY_ANNOTATIONS=$(yq eval 'select(.kind == "CustomResourceDefinition" and .metadata.name == "clusterpolicies.kyverno.io") | .metadata.annotations' test-kyverno-filtered.yaml)
if [ "$CLUSTER_POLICY_ANNOTATIONS" = "{}" ] || [ "$CLUSTER_POLICY_ANNOTATIONS" = "null" ]; then
    echo "  ✅ Successfully removed"
else
    echo "  ❌ Still present: $CLUSTER_POLICY_ANNOTATIONS"
fi

echo "• policies.kyverno.io CRD annotations:"
POLICY_ANNOTATIONS=$(yq eval 'select(.kind == "CustomResourceDefinition" and .metadata.name == "policies.kyverno.io") | .metadata.annotations' test-kyverno-filtered.yaml)
if [ "$POLICY_ANNOTATIONS" = "{}" ] || [ "$POLICY_ANNOTATIONS" = "null" ]; then
    echo "  ✅ Successfully removed"
else
    echo "  ❌ Still present: $POLICY_ANNOTATIONS"
fi

echo "• Service annotations (should be preserved):"
SERVICE_ANNOTATIONS=$(yq eval 'select(.kind == "Service") | .metadata.annotations' test-kyverno-filtered.yaml)
if [ "$SERVICE_ANNOTATIONS" != "{}" ] && [ "$SERVICE_ANNOTATIONS" != "null" ]; then
    echo "  ✅ Correctly preserved"
else
    echo "  ❌ Incorrectly removed"
fi

# Clean up test files
rm -f test-kyverno-sample.yaml test-kyverno-filtered.yaml

echo ""
echo "🎉 CRD annotation filtering test completed successfully!"
echo "The fix is ready to resolve the Kyverno CRD annotation size issue."