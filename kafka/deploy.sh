#!/bin/bash
# Script to set up Kafka environment with UI

# Define namespace and Kafka Helm chart details
NAMESPACE="kafka"
KAFKA_HELM_CHART="oci://registry-1.docker.io/bitnamicharts/kafka"
KAFKA_RELEASE_NAME="my-kafka"
KAFKA_UI_HELM_REPO="https://provectus.github.io/kafka-ui-charts"
KAFKA_UI_RELEASE_NAME="kafka-ui"
KAFKA_UI_VALUES_FILE="./kafka-ui-values.yaml"

# Function to create namespace if it does not exist
create_namespace() {
    if kubectl get ns | grep -q "^$NAMESPACE "; then
        echo "Namespace '$NAMESPACE' already exists"
    else
        echo "Creating namespace '$NAMESPACE'"
        kubectl create ns "$NAMESPACE"
    fi
}

# Install or upgrade Kafka using Helm
install_or_upgrade_kafka() {
    echo "Installing or upgrading Kafka with Helm"
    helm upgrade --install "$KAFKA_RELEASE_NAME" "$KAFKA_HELM_CHART" --namespace "$NAMESPACE"
}

# Install or upgrade Kafka UI using Helm
install_or_upgrade_kafka_ui() {
    echo "Adding Kafka UI Helm repository"
    helm repo add kafka-ui "$KAFKA_UI_HELM_REPO"
    helm repo update
    echo "Installing or upgrading Kafka UI"
    helm upgrade --install "$KAFKA_UI_RELEASE_NAME" kafka-ui/kafka-ui --namespace "$NAMESPACE" -f "$KAFKA_UI_VALUES_FILE"
}

# Main execution
create_namespace
install_or_upgrade_kafka
# install_or_upgrade_kafka_ui

echo "Kafka environment setup complete."
