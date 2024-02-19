#!/bin/bash

# Function to delete the metallb-system namespace
delete_metallb_namespace() {
  kubectl delete namespace metallb-system
}

# Uninstall Metallb
uninstall_metallb() {
  helm uninstall metallb -n metallb-system
}

# Function to remove Metallb additional resources
remove_metallb_resources() {
  kubectl delete -n metallb-system ipaddresspool my-pool
  kubectl delete -n metallb-system l2advertisement example
}

# Function to remove CRDs and other Metallb-related resources
remove_metallb_crd_resources() {
  kubectl delete customresourcedefinition.apiextensions.k8s.io/addresspools.metallb.io 
  kubectl delete customresourcedefinition.apiextensions.k8s.io/bfdprofiles.metallb.io 
  kubectl delete customresourcedefinition.apiextensions.k8s.io/bgpadvertisements.metallb.io 
  kubectl delete customresourcedefinition.apiextensions.k8s.io/bgppeers.metallb.io 
  kubectl delete customresourcedefinition.apiextensions.k8s.io/communities.metallb.io 
  kubectl delete customresourcedefinition.apiextensions.k8s.io/ipaddresspools.metallb.io 
  kubectl delete customresourcedefinition.apiextensions.k8s.io/l2advertisements.metallb.io 
}

# Function to remove service accounts, roles, role bindings, and other Metallb-related resources
remove_metallb_rbac_resources() {
  kubectl delete serviceaccount/controller 
  kubectl delete serviceaccount/speaker 
  kubectl delete role.rbac.authorization.k8s.io/controller 
  kubectl delete role.rbac.authorization.k8s.io/pod-lister 
  kubectl delete clusterrole.rbac.authorization.k8s.io/metallb-system:controller 
  kubectl delete clusterrole.rbac.authorization.k8s.io/metallb-system:speaker 
  kubectl delete rolebinding.rbac.authorization.k8s.io/controller 
  kubectl delete rolebinding.rbac.authorization.k8s.io/pod-lister 
  kubectl delete clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller 
  kubectl delete clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker 
}

# Function to remove other Metallb-related resources
remove_metallb_other_resources() {
  kubectl delete configmap/metallb-excludel2 
  kubectl delete secret/webhook-server-cert 
  kubectl delete service/webhook-service 
  kubectl delete deployment.apps/controller 
  kubectl delete daemonset.apps/speaker 
  kubectl delete validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration
}

# Function to remove jq if it was installed during setup
remove_jq() {
  if command -v jq &> /dev/null; then
    echo "jq was installed by the setup script. Removing..."
    sudo apt-get remove -y jq
  fi
}

# Uninstall Metallb
uninstall_metallb

# Delete the metallb-system namespace
delete_metallb_namespace

# Remove additional Metallb resources
remove_metallb_resources

# Remove CRDs and other Metallb-related resources
remove_metallb_crd_resources

# Remove service accounts, roles, role bindings, and other Metallb-related resources
remove_metallb_rbac_resources

# Remove other Metallb-related resources
remove_metallb_other_resources

# Remove jq if it was installed
# remove_jq

echo "Rollback completed. Metallb, additional resources, and related resources have been removed."
