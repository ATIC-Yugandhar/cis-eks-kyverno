#!/bin/bash

rm -f reports/results-kyverno-tests.txt
rm -f reports/results-kyverno-summary.txt
rm -rf reports/compliance
rm -f reports/policy-tests/*.txt
rm -f reports/terraform-compliance/*.yaml
rm -f reports/integration-tests/*.yaml
rm -f demo-kind-kyverno/reports/*.yaml

mkdir -p reports/policy-tests
mkdir -p reports/terraform-compliance
mkdir -p reports/integration-tests

echo "Old report structure cleaned up"