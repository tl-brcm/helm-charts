#!/bin/bash

# Define variables
HELM_REPO_NAME="splunk"
HELM_REPO_URL="https://splunk.github.io/splunk-operator/"
NAMESPACE="splunk-operator"
RELEASE_NAME="splunk-operator-test"

# Add the Splunk Helm repository
echo "Adding Splunk Helm repository..."
helm repo add "$HELM_REPO_NAME" "$HELM_REPO_URL"

# Update Helm repositories
echo "Updating Helm repositories..."
helm repo update

# Create the namespace if it doesn't exist
if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' already exists"
else
    echo "Creating namespace '$NAMESPACE'..."
    kubectl create namespace "$NAMESPACE"
fi

# Install Splunk Operator using Helm
if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
    echo "Helm release '$RELEASE_NAME' already installed in namespace '$NAMESPACE'"
else
    echo "Installing Splunk Operator with Helm..."
    helm install "$RELEASE_NAME" "$HELM_REPO_NAME"/splunk-operator -n "$NAMESPACE"
fi

# Apply ingress configuration
echo "Applying ingress configuration..."
kubectl apply -f ingress.yaml

# Apply Splunk Standalone configuration
echo "Applying Splunk Standalone configuration..."
kubectl apply -f splunk-standalone.yaml

echo "Deployment is successful. Run the below command to get the default admin password:"
echo "kubectl get secrets splunk-s1-standalone-secret-v1 -n splunk-operator -o go-template='{{range \$k,\$v := .data}}{{printf \"%s: \" \$k}}{{if not \$v}}{{\$v}}{{else}}{{\$v | base64decode}}{{end}}{{\"\\n\"}}{{end}}'"