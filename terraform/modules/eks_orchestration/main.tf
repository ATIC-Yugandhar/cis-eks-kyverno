terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
  }
}

provider "kubernetes" {
  # Assumes provider configuration is handled at a higher level or via environment variables
}

# Kyverno policies from kyverno-policies/
locals {
  kyverno_policy_files = [
    "${path.module}/../../../kyverno-policies/cis-4.1.1.yaml",
    "${path.module}/../../../kyverno-policies/cis-4.1.2.yaml",
    "${path.module}/../../../kyverno-policies/cis-4.1.3.yaml",
    "${path.module}/../../../kyverno-policies/cis-4.1.4.yaml",
    "${path.module}/../../../kyverno-policies/custom-3.2.1.yaml",
    "${path.module}/../../../kyverno-policies/custom-3.2.2.yaml",
    "${path.module}/../../../kyverno-policies/custom-4.1.8.yaml",
    "${path.module}/../../../kyverno-policies/custom-4.5.1.yaml"
  ]
}

resource "kubernetes_manifest" "kyverno_policy" {
  for_each = { for file in local.kyverno_policy_files : file => file }

  manifest = yamldecode(file(each.value))
}