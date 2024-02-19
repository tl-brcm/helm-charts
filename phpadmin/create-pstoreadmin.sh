#!/bin/bash
NAMESPACE="ssorest-pstore"
DEPLOYMENT_NAME="phpadmin"
HELM_REPO_URL_BASE="oci://registry-1.docker.io/bitnamicharts"
HELM_CHART_NAME="phpmyadmin"
HELM_REPO_URL="$HELM_REPO_URL_BASE/$HELM_CHART_NAME"

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Function to create the ssorest-pstore namespace
create_namespace() {
  if kubectl get namespace "$1" &> /dev/null; then
    echo "Namespace $1 already exists."
  else
    echo "Creating namespace $1."
    kubectl create namespace "$1"
  fi
}



# Function to install or upgrade Helm chart
install_or_upgrade_chart() {
  if helm list -n "$NAMESPACE" | grep -q "$DEPLOYMENT_NAME"; then
    echo "Upgrading existing Helm release ${DEPLOYMENT_NAME} in namespace ${NAMESPACE}."
    helm upgrade $DEPLOYMENT_NAME $HELM_REPO_URL -n $NAMESPACE -f "${SCRIPT_DIR}/values.yaml"
  else
    echo "Installing new Helm release ${DEPLOYMENT_NAME} in namespace ${NAMESPACE}."
    helm install $DEPLOYMENT_NAME $HELM_REPO_URL -n $NAMESPACE -f "${SCRIPT_DIR}/values.yaml"
  fi
}

# Create the ssorest-pstore namespace
create_namespace $NAMESPACE

# Install or upgrade Helm chart
install_or_upgrade_chart

# Wait for all MySQL pods to be in Running state
$SCRIPT_DIR/../utils/check_pods_ready.sh  $NAMESPACE "app.kubernetes.io/name=${HELM_CHART_NAME}"
