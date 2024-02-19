#!/bin/bash

# This script checks if all pods with a given label in a specified namespace are ready.

# Check if the correct number of arguments is given
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <namespace> <label-selector>"
    exit 1
fi

NAMESPACE=$1
LABEL_SELECTOR=$2

# Function to check if all pods are ready in the given namespace and with the given label selector
check_pods_ready() {
  local total_pods
  local ready_pods

  while true; do
    # Get the status of the pods
    pod_status=$(kubectl get pods -n "$NAMESPACE" -l "$LABEL_SELECTOR" -o json)

    # Extract total and ready pod counts
    total_pods=$(echo "$pod_status" | jq -r '.items | length')
    ready_pods=$(echo "$pod_status" | jq -r '[.items[] | select(.status.phase == "Running") | .metadata.name] | length')

    # Check if all pods are ready
    if [ "$total_pods" -eq "$ready_pods" ] && [ "$total_pods" -gt 0 ]; then
      echo "All pods are in the Running state."
      break
    fi

    # Print status and wait for a few seconds before checking again
    echo "Total pods: $total_pods, Ready pods: $ready_pods. Waiting..."
    sleep 5
  done
}

# Call the function with provided namespace and label selector
check_pods_ready "$NAMESPACE" "$LABEL_SELECTOR"
