#!/bin/bash

# Specify the namespace you want to inspect
NAMESPACE="siteminder"

# Get the total requested CPU resources in the namespace
total_cpu_requests=0

# Loop through each line in the output of 'kubectl get pods'
while IFS= read -r line; do
    # Extract the CPU requests value and sum it up
    cpu_request=$(echo "$line" | awk '{print $2}' | sed 's/m//g') # Remove 'm' to treat as numeric
    total_cpu_requests=$((total_cpu_requests + cpu_request))
done < <(kubectl get pods -n "$NAMESPACE" -o=custom-columns=NAME:.metadata.name,CPU_REQUESTS:.spec.containers[*].resources.requests.cpu --no-headers)

# Convert to millicores if you prefer
echo "Total CPU Requests in namespace '$NAMESPACE': ${total_cpu_requests}m"