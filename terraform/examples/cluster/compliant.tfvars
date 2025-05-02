# Terraform variables for the COMPLIANT EKS cluster example

mode = "compliant"

# CIS-compliant settings

# 2.1.1 - Enable all audit log types
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# 4.1.7 - Use Cluster Access Manager
use_cluster_access_manager = true

# 5.3.1 - Enable secrets encryption with KMS
enable_secrets_encryption = true
kms_key_deletion_window = 7
kms_key_enable_rotation = true

# 5.4.1 & 5.4.2 - Restrict control plane access and use private endpoint
endpoint_private_access = true
endpoint_public_access = false
public_access_cidrs = ["10.0.0.0/8"]  # Restricted instead of 0.0.0.0/0

# 5.4.3 - Use private subnets for nodes
use_private_subnets_for_nodes = true

# Configure Node settings for CIS compliance
node_user_data = <<-EOT
#!/bin/bash
# 3.2.1 - Disable anonymous auth
echo 'kubelet --anonymous-auth=false' >> /etc/kubernetes/kubelet.conf

# 3.2.3 - Set client CA file
echo 'kubelet --client-ca-file=/etc/kubernetes/pki/ca.crt' >> /etc/kubernetes/kubelet.conf

# 3.2.4 - Disable read-only port
echo 'kubelet --read-only-port=0' >> /etc/kubernetes/kubelet.conf

# 3.2.5 - Set streaming connection timeout (not zero)
echo 'kubelet --streaming-connection-idle-timeout=5m' >> /etc/kubernetes/kubelet.conf

# 3.2.6 - Enable iptables chains
echo 'kubelet --make-iptables-util-chains=true' >> /etc/kubernetes/kubelet.conf

# 3.2.7 - Set eventRecordQPS
echo 'kubelet --eventRecordQPS=5' >> /etc/kubernetes/kubelet.conf

# 3.2.8 - Enable certificate rotation
echo 'kubelet --rotate-certificates=true' >> /etc/kubernetes/kubelet.conf

# 3.2.9 - Enable kubelet server certificate rotation
cat <<EOF > /etc/kubernetes/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
featureGates:
  RotateKubeletServerCertificate: true
EOF

# 3.1.1-3.1.4 - Set correct permissions for kubeconfig and kubelet config files
chmod 644 /etc/kubernetes/kubelet.conf
chmod 644 /etc/kubernetes/kubelet-config.yaml
chown root:root /etc/kubernetes/kubelet.conf
chown root:root /etc/kubernetes/kubelet-config.yaml
EOT

# 5.1.1 - Set up ECR image scanning
enable_ecr_scanning = true

# 5.1.3 - Readonly ECR access for nodes
enable_readonly_ecr_access = true

# 5.4.5 - TLS for load balancers
enable_tls_for_lb = true 

# Security group settings
restricted_sg_rules = true