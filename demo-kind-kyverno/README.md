# Demo: Kind Kubernetes Cluster with Kyverno Validation

## Prerequisites

- Docker  
- Kind (Kubernetes in Docker)
  • Install via Homebrew: `brew install kind`, or
  • Download to `~/.local/bin` and ensure `$HOME/.local/bin` is in your `PATH`
- kubectl  
- Kyverno CLI  

## Configuration

- [`kind-cluster-config.yaml`](demo-kind-kyverno/kind-cluster-config.yaml:1): Kind cluster definition  

## Scripts

### [`create_cluster.sh`](demo-kind-kyverno/create_cluster.sh:1)  
Orchestrates the full demo: creates the Kind cluster, deploys application manifests, runs resource description and Kyverno validation, and cleans up.

### [`describe_resources.sh`](demo-kind-kyverno/describe_resources.sh:1)  
Describes all cluster resources and exports them to `resources.json`.  

### [`run_kyverno.sh`](demo-kind-kyverno/run_kyverno.sh:1)
- Applies all Kyverno policies from the `kyverno-policies` directory against `resources.json` and outputs results to `kyverno_report.json`.
- Runs `kyverno test` against sample manifests in `manifests/` and outputs results to `tests_report.json`.

## Usage

```bash
cd demo-kind-kyverno
chmod +x *.sh
./create_cluster.sh
```

After execution, inspect:
- `reports/resources.json` for current cluster state in JSON
- `reports/kyverno_report.json` for policy validation results
- `reports/tests_report.json` for manifest test results

After execution, inspect:  
- `resources.json` for current cluster state in JSON  
- `kyverno_report.json` for policy validation results