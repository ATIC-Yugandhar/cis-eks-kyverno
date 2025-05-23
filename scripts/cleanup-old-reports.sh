#!/bin/bash

rm -f reports/results-kyverno-tests.txt
rm -f reports/results-kyverno-summary.txt
rm -rf reports/compliance

mkdir -p reports/policy-tests
mkdir -p reports/terraform-compliance
mkdir -p reports/integration-tests

echo "Old report structure cleaned up"