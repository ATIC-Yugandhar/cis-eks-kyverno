# Kube-bench Integration

This directory contains the kube-bench integration for CIS compliance scanning within Kubernetes clusters.

## Overview

Kube-bench runs as Kubernetes Jobs on worker nodes to perform CIS compliance scans. The results are collected and integrated with Kyverno policy validation.

## Components

- `job-node.yaml`: Kube-bench job for worker node scanning
- `job-master.yaml`: Kube-bench job for control-plane scanning  
- `rbac.yaml`: RBAC permissions for kube-bench jobs

## Usage

The kube-bench integration is built into the test framework. To run kube-bench scanning:

```bash
# Run complete testing with kube-bench integration
./scripts/test-kind-cluster.sh

# View kube-bench results
kubectl logs -l app=kube-bench,component=node

# Check generated reports
ls reports/kind-cluster/kube-bench/
```

## Integration with Testing

The kube-bench scans are integrated into the existing test workflow:
- `scripts/test-kind-cluster.sh` will run kube-bench automatically
- Results are collected in `reports/kube-bench/`
- Policies reference kube-bench findings through annotations