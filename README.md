# EKS CIS Benchmarks with Terraform and Kyverno

## Overview

This project provides Terraform modules to provision Amazon EKS (Elastic Kubernetes Service) clusters according to CIS (Center for Internet Security) benchmarks, offering both compliant and non-compliant configurations for demonstration and testing purposes. It also includes a suite of Kyverno policies designed to enforce or audit these CIS benchmarks within the EKS environment. The goal is to help users establish and maintain a secure EKS cluster configuration aligned with industry best practices.

## Repository Structure

```
.
├── .github/workflows/      # GitHub Actions for CI (Terraform fmt/validate, Kyverno test/apply)
├── docs/                   # Detailed documentation (see cis-eks-kyverno.md)
├── kyverno-policies/cis/   # Kyverno policies and tests mapped to EKS CIS controls
├── noncompliant-resources/ # Example Kubernetes manifests that violate policies (for testing)
├── scripts/                # Helper scripts (e.g., validate-cis.sh for applying policies)
├── terraform/
│   ├── modules/            # Reusable Terraform modules (eks_cluster_compliant, eks_cluster_non_compliant)
│   └── examples/           # Usage examples for the Terraform modules
├── CONTRIBUTING.md         # Contribution guidelines
├── LICENSE                 # Project license
└── README.md               # This file
```

*   **`.github/workflows/`**: Contains GitHub Actions workflows for continuous integration checks, including Terraform formatting/validation and Kyverno policy testing/application simulations.
*   **`docs/`**: Houses detailed documentation, including the comprehensive guide `cis-eks-kyverno.md`.
*   **`kyverno-policies/cis/`**: Contains Kyverno policies (`.yaml`) and their corresponding tests (`*-test.yaml`), organized according to the EKS CIS benchmark controls they address. Policies are structured into:
    *   `supported/`: Policies for CIS controls generally addressable by Kyverno (based on community policies or direct mapping).
    *   `custom/`: Custom policies attempting to address controls not directly covered or requiring specific interpretations (e.g., 4.1.8, 4.5.1, 5.2.1).
*   **`noncompliant-resources/`**: Provides example Kubernetes manifest files intentionally designed to violate specific Kyverno policies, useful for testing policy enforcement and audit capabilities.
*   **`scripts/`**: Includes helper scripts. Notably, `validate-cis.sh` can be used to apply Kyverno policies against a directory of manifest files to check for violations.
*   **`terraform/modules/`**: Contains the core reusable Terraform modules for creating EKS clusters:
    *   `eks_cluster_compliant`: Provisions an EKS cluster configured to meet CIS benchmark recommendations.
    *   `eks_cluster_non_compliant`: Provisions an EKS cluster with configurations that intentionally deviate from CIS benchmarks, useful for demonstrating policy enforcement.
*   **`terraform/examples/`**: Provides practical examples demonstrating how to use the Terraform modules to provision compliant and non-compliant clusters.

## Terraform Usage

While the `scripts/automated_deploy_test_destroy.sh` script (detailed in the "Automated Deployment and Testing Workflow" section) provides a fully automated workflow, you can also use Terraform manually if needed. Note that the automated script handles backend creation. If running manually, ensure your backend is configured appropriately.

**Manual Terraform Steps:**

1.  **Modules Location:** The reusable Terraform modules are located in the `terraform/modules/` directory.
2.  **Examples Location:** Usage examples demonstrating how to use the modules are in `terraform/examples/`.
3.  **Navigate to an Example:** Change your directory to one of the example folders:
    ```bash
    # For the compliant cluster example
    cd terraform/examples/compliant_cluster/

    # Or for the non-compliant cluster example
    cd terraform/examples/non_compliant_cluster/
    ```
4.  **Configure Provider:** Ensure the AWS provider details (like region) are correctly set in `providers.tf` for your environment. The backend configuration is handled separately in `backend.tf` (see next section).
5.  **Run Terraform Commands:** Execute the standard Terraform workflow:
    ```bash
    terraform init    # Initialize the Terraform working directory (downloads providers, configures backend)
    terraform plan    # Review the planned infrastructure changes
    terraform apply   # Apply the changes to create the EKS cluster
    ```

### Backend Setup

The `scripts/automated_deploy_test_destroy.sh` script handles the creation and configuration of the required Terraform backend resources (S3 bucket and DynamoDB table) automatically, using variables defined within the script. There is no need for manual backend setup when using the automated script.

If you choose to run Terraform manually outside of the automated script, you will need to configure your backend appropriately in the `backend.tf` files within the `terraform/examples/` directories.

## Kyverno Usage

The `scripts/automated_deploy_test_destroy.sh` script automates the installation of Kyverno and the application of policies as part of its workflow. However, you can also interact with Kyverno and the policies manually or use the `validate-cis.sh` script for local checks.

1.  **Policies Location:** Kyverno policies mapped to CIS benchmarks are located under `kyverno-policies/cis/`, categorized into `supported/` and `custom/` subdirectories as described in the "Repository Structure" section. Each policy file (`.yaml`) often has a corresponding test file (`*-test.yaml`).
2.  **Validate Manifests (Offline):** Use the `validate-cis.sh` script (which wraps the Kyverno CLI) to recursively apply policies from `kyverno-policies/cis/` against local Kubernetes manifest files and check for violations *before* applying them to a cluster. Pass the directory containing the manifests as an argument:
   ```bash
   # Example: Check non-compliant resources against all CIS policies
   ./scripts/validate-cis.sh noncompliant-resources/ kyverno-policies/cis/
   ```
3.  **Run Kyverno Tests (Offline):** Use the Kyverno CLI to recursively run the predefined unit tests located under `kyverno-policies/cis/`. This validates policy logic without needing a cluster. Navigate to the repository root and run:
   ```bash
   # Ensure Kyverno CLI is installed
   kyverno test kyverno-policies/cis/ --recursive
   ```
   This command recursively executes the tests defined in the `*-test.yaml` files against the corresponding policies within the `cis` directory.
4.  **Apply Policies to Cluster (Manual):** If managing Kyverno manually (not using the `automated_deploy_test_destroy.sh` script), you can recursively apply all policies from the `cis` directory to your cluster using `kubectl`:
   ```bash
   # Ensure kubectl is configured for your target cluster
   kubectl apply -f kyverno-policies/cis/ -R
   ```

## CIS Compliance

For a detailed breakdown of which EKS CIS benchmark controls are covered by the Kyverno policies in this repository, please refer to the [CIS EKS Kyverno Mapping document](docs/cis-eks-kyverno.md).

## Coverage and Limitations

It's important to understand the scope of Kyverno's capabilities in the context of EKS CIS benchmarks. Kyverno operates as an admission controller and policy engine within the Kubernetes API.

**Kyverno CANNOT directly enforce or audit:**

*   **Host-level configurations:** This includes settings within kubelet configuration files, file permissions on nodes (e.g., `/etc/kubernetes/pki/`, `/var/lib/kubelet/`), or kernel parameters. (Relevant CIS sections: 4.1.x, 4.2.x)
*   **API Server / Kubelet Startup Flags:** Kyverno cannot verify the flags used to start the Kubernetes control plane components (API server, controller manager, scheduler) or the kubelet process itself. (Relevant CIS sections: 1.x, 4.2.x)
*   **External AWS Resource Configurations:** Kyverno does not interact with or audit AWS resources outside the Kubernetes API. This includes:
   *   ECR image scanning status (CIS 4.4.1 - requires external tooling).
   *   KMS key rotation status (CIS 3.1.1).
   *   IAM user configurations (CIS 5.1.1-5.1.3).
   *   Security Groups for the control plane endpoint (CIS 5.4.1-5.4.3).
   *   Secrets Manager/Parameter Store usage for secrets (CIS 5.5.1).
*   **Infrastructure Settings:** While Terraform in this project handles provisioning private nodes and endpoints (CIS 2.1.1, 2.1.2), Kyverno itself cannot enforce these infrastructure-level settings.
*   **Audit Log Configuration:** Enabling and configuring audit logs (CIS 3.2.1) is done via API server flags, which Kyverno cannot check.

**Summary of Primarily Unsupported CIS Control Categories:**

*   Section 1: Control Plane Component Configuration (Startup Flags)
*   Section 2: Control Plane Node Configuration (Networking, Private Endpoints - handled by Infra)
*   Section 3: Etcd and Control Plane Logging (KMS, Audit Logs)
*   Section 4: Worker Node Configuration (Kubelet files, permissions, startup flags) - *Partial coverage via runtime checks possible for some aspects.*
*   Section 5: Policies (IAM, Secrets Management, Network Policies - *Partial coverage*, ECR, Security Groups)

Refer to the [CIS EKS Kyverno Mapping document](docs/cis-eks-kyverno.md) for specific control coverage details.
For a detailed breakdown of specific CIS controls that fall outside Kyverno's scope and the reasons why, please see the [Kyverno Limitations for EKS CIS Benchmarks](./docs/kyverno-limitations.md) document.

## Contributing

Contributions are welcome! Please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file.

## Automated Deployment and Testing Workflow

This repository includes the `scripts/automated_deploy_test_destroy.sh` script designed to fully automate the deployment, testing, and cleanup process. It handles backend setup, provisions compliant and non-compliant clusters, installs Kyverno, applies policies, tests against non-compliant resources, and finally destroys all created infrastructure.

**Configuration:**

Before running the script, review and potentially modify the configuration variables defined at the top of `scripts/automated_deploy_test_destroy.sh`. These include settings like `AWS_REGION`, cluster names (`COMPLIANT_CLUSTER_NAME`, `NON_COMPLIANT_CLUSTER_NAME`), backend resource names (`TF_BACKEND_BUCKET`, `TF_BACKEND_DYNAMODB_TABLE`), and others. Ensure these values are appropriate for your AWS environment and naming conventions.

**Execution:**

1.  **Make Script Executable:**
    ```bash
    chmod +x scripts/automated_deploy_test_destroy.sh
    ```
2.  **Run the Script:**
    ```bash
    ./scripts/automated_deploy_test_destroy.sh
    ```
The script will then execute the following sequence automatically:
    *   Create Terraform backend resources (S3 bucket, DynamoDB table).
    *   Deploy the **compliant** EKS cluster using Terraform.
    *   Install Kyverno via Helm and recursively apply CIS policies from `kyverno-policies/cis/`.
    *   Attempt to apply non-compliant resources and report results.
    *   Destroy the compliant cluster.
    *   Deploy the **non-compliant** EKS cluster using Terraform.
    *   Install Kyverno via Helm and recursively apply CIS policies from `kyverno-policies/cis/`.
    *   Attempt to apply non-compliant resources and report results.
    *   Destroy the non-compliant cluster.
    *   Destroy the Terraform backend resources.

**Important Warnings:**

*   **Prerequisites:** Ensure you have the following tools installed and configured **before** running the script:
    *   AWS CLI (with active credentials/profile providing sufficient permissions).
    *   Terraform.
    *   kubectl.
    *   Helm.
    *   jq.
*   **`-auto-approve` Risk:** The script uses `terraform apply -auto-approve` and `terraform destroy -auto-approve` for automation. This bypasses manual confirmation steps. **RUN THIS SCRIPT ONLY IN ISOLATED TEST ACCOUNTS WHERE ACCIDENTAL RESOURCE MODIFICATION OR DELETION IS ACCEPTABLE.** Do not run this in production or critical environments.
*   **Resource Costs:** Running this script will provision AWS resources (EKS clusters, VPCs, S3, DynamoDB, etc.) that incur costs. Ensure you understand the potential costs involved. The script attempts to clean up all resources, but verification is recommended.

**Results:**

The script creates a timestamped directory under `results/` (e.g., `results/2023-10-27_10-30-00/`). Inside this directory, you will find text files (`*.txt`) containing the output of Kyverno policy reports generated during the tests against both the compliant and non-compliant clusters. This allows you to review the policy enforcement behavior observed during the automated run.
