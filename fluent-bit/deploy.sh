#!/bin/bash

# Define the namespace
NAMESPACE="fluent"

# Get the absolute path of the script's directory
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define the absolute path for values.yaml
VALUES_FILE="${SCRIPT_DIR}/values.yaml"

# Add the Fluent Bit Helm chart repository and update
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Check if the namespace exists
if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo "Namespace $NAMESPACE already exists"
else
    echo "Creating namespace $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
fi

# Check if the Fluent Bit release is already installed
if helm list -n "$NAMESPACE" | grep -q 'fluent-bit'; then
    echo "Fluent Bit is already installed, upgrading..."
    helm upgrade fluent-bit fluent/fluent-bit --namespace "$NAMESPACE" -f "$VALUES_FILE"
else
    echo "Installing Fluent Bit..."
    helm install fluent-bit fluent/fluent-bit --namespace "$NAMESPACE" -f "$VALUES_FILE"
fi
