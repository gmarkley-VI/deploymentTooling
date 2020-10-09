#!/bin/bash -i

#create the config
if [ -n "$1" ]; then
  DIR="$(echo $1 | tr -d \/)"
  if [ ! -f $DIR/install-config.yaml ]; then
    PREWD="$(pwd)"
    tools/openshift-install create install-config --dir=$DIR
    sed -i 's/OpenShiftSDN/OVNKubernetes/g' $DIR/install-config.yaml
    tools/openshift-install create manifests --dir=$DIR
    patch $DIR/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch
    cp $DIR/manifests/cluster-network-02-config.yml $DIR/manifests/cluster-network-03-config.yml
    patch $DIR/manifests/cluster-network-03-config.yml backups/cluster-network-03-config.patch
    echo "Patching Complete Preparing to install"
    tools/openshift-install create cluster --dir=$DIR
    echo "Install is completed"
    export KUBECONFIG=$PREWD/$DIR/auth/kubeconfig
    tools/oc get nodes
    HYBRID="$(tools/oc get network.operator cluster -o yaml | grep -cim1 hybridClusterNetwork)"
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
