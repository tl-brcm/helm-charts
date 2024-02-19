#!/bin/bash

# Variables
REPO_NAME="ingress-nginx"
REPO_URL="https://kubernetes.github.io/ingress-nginx/"
NAMESPACE="ingress"
RELEASE_NAME="nginx-ingress"
CHART_NAME="$REPO_NAME/ingress-nginx"
VALUES_FILE="./values.yaml"

# Add the Helm repository for ingress-nginx
helm repo add "$REPO_NAME" "$REPO_URL"

# Update the Helm repository to make sure we have the latest charts
helm repo update

# Create the Kubernetes namespace for ingress
kubectl create ns "$NAMESPACE"

# Install the ingress-nginx using Helm in the specified namespace with the given values file
helm install "$RELEASE_NAME" "$CHART_NAME" -f "$VALUES_FILE" -n "$NAMESPACE"
