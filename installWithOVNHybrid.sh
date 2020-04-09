#!/bin/bash -i

#create the config
if [ -n "$1" ]; then
  $1="$(echo $1 | tr -d \/)"
  if [ ! -f $1/install-config.yaml ]; then
    PREWD="$(pwd)"
    openshift-install create install-config --dir=$1
    sed -i 's/OpenShiftSDN/OVNKubernetes/g' $1/install-config.yaml
    openshift-install create manifests --dir=$1
    patch $1/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch
    cp $1/manifests/cluster-network-02-config.yml $1/manifests/cluster-network-03-config.yml
    patch $1/manifests/cluster-network-03-config.yml backups/cluster-network-03-config.patch
    echo "Patching Complete Preparing to install"
    openshift-install create cluster --dir=$1
    echo "Install is completed"
    export KUBECONFIG=$PREWD/$1/auth/kubeconfig
    oc get nodes
    HYBRID="$(oc get network.operator cluster -o yaml | grep -cim1 hybridClusterNetwork)"
    if [ "$HYBRID" = 0 ]; then
      echo "Hybrid network did not setup correctly"
      exit
    else
      echo "Hybrid network is setup."
    fi
  fi
else
  echo "Install directory not supplied."
fi
