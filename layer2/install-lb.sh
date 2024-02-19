#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Function to create the metallb-system namespace
create_metallb_namespace() {
  kubectl create namespace metallb-system
}

# Install jq if not already installed
install_jq() {
  if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y jq
  fi
}

# Install the metallb-system in the metallb-system namespace
install_metallb() {
  helm repo add metallb https://metallb.github.io/metallb
  helm install metallb metallb/metallb --version 0.13.11 -n metallb-system
}

# Function to check if all Metallb speakers are in Running state
check_speakers_running() {
  local desired_pods
  local current_pods
  local ready_pods

  echo "Waiting for 10 seconds before checking MetalLB speaker pods..."
  sleep 10

  while true; do
    # Get the status of the Metallb DaemonSet in the metallb-system namespace
    daemonset_status=$(kubectl get daemonset -n metallb-system metallb-speaker -o json)

    # Extract desired, current, and ready pod counts
    desired_pods=$(echo "$daemonset_status" | jq -r '.status.desiredNumberScheduled')
    current_pods=$(echo "$daemonset_status" | jq -r '.status.currentNumberScheduled')
    ready_pods=$(echo "$daemonset_status" | jq -r '.status.numberReady')

    # Check if all desired pods are ready
    if [ "$desired_pods" -eq "$ready_pods" ]; then
      echo "All Metallb speakers are in the Running state."
      break
    fi

    # Print status and wait for a few seconds before checking again
    echo "Desired: $desired_pods, Current: $current_pods, Ready: $ready_pods. Waiting..."
    sleep 5
  done
}

# Create the metallb-system namespace
create_metallb_namespace

# Install jq if not already installed
install_jq

# Install Metallb in the metallb-system namespace
install_metallb

# Wait for all Metallb speakers to be in Running state
check_speakers_running

# Apply the layer2 configuration
kubectl apply -f "${SCRIPT_DIR}/l2.yaml" -n metallb-system

# Deploy and apply the L2Advertisement configuration
kubectl apply -f "${SCRIPT_DIR}/advertise.yaml" -n metallb-system
