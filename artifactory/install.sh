helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/
helm install ustore helm-openldap/openldap-stack-ha

#!/bin/bash
NAMESPACE="ssorest-ustore"
DEPLOYMENT_NAME="ustore"
HELM_REPO_URL_BASE="https://jp-gouin.github.io"
HELM_REPO_NAME="helm-openldap"
HELM_CHART_NAME="openldap-stack-ha"
HELM_REPO_URL="$HELM_REPO_URL_BASE/$HELM_REPO_NAME/"

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Function to create the namespace
create_namespace() {
  if kubectl get namespace "$1" &> /dev/null; then
    echo "Namespace $1 already exists."
  else
    echo "Creating namespace $1."
    kubectl create namespace "$1"
  fi
}

# Function to create secrets
create_secrets() {
  kubectl apply -f "${SCRIPT_DIR}/secrets.yaml" -n ${NAMESPACE}
}

# Function to add Helm repository if it's not already added
add_helm_repo_if_not_exists() {
  if helm repo list | grep -q "$HELM_REPO_NAME"; then
    echo "Helm repo $HELM_REPO_NAME already exists."
  else
    echo "Adding Helm repo $HELM_REPO_NAME."
    helm repo add "$HELM_REPO_NAME" "$HELM_REPO_URL"
    helm repo update
  fi
}

# Function to install or upgrade Helm chart
install_or_upgrade_chart() {
  # Get the status of the deployment
  DEPLOYMENT_STATUS=$(helm list -n "$NAMESPACE" | awk -v name="$DEPLOYMENT_NAME" '$1 == name {print $8}')

  if [ "$DEPLOYMENT_STATUS" = "deployed" ]; then
    echo "Upgrading existing Helm release ${DEPLOYMENT_NAME} in namespace ${NAMESPACE}."
    helm upgrade $DEPLOYMENT_NAME "$HELM_REPO_NAME/$HELM_CHART_NAME" -n $NAMESPACE -f "${SCRIPT_DIR}/values.yaml"
  else
    echo "Installing new Helm release ${DEPLOYMENT_NAME} in namespace ${NAMESPACE}."
    helm install $DEPLOYMENT_NAME "$HELM_REPO_NAME/$HELM_CHART_NAME" -n $NAMESPACE -f "${SCRIPT_DIR}/values.yaml"
  fi
}

# Create the namespace
create_namespace $NAMESPACE

# Create secrets
create_secrets

# Add Helm repository if it does not exist
add_helm_repo_if_not_exists

# Install or upgrade Helm chart
install_or_upgrade_chart

# Wait for all related pods to be in Running state
$SCRIPT_DIR/../utils/check_pods_ready.sh  $NAMESPACE "app.kubernetes.io/name=${HELM_CHART_NAME}"
