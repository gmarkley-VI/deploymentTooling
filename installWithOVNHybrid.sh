#!/bin/bash -i

#create the config
if [ -n "$1" ]; then
  DIR="$(echo $1 | tr -d \/)"
  if [ ! -f $DIR/install-config.yaml ]; then
    PREWD="$(pwd)"
    openshift-install create install-config --dir=$DIR
    sed -i 's/OpenShiftSDN/OVNKubernetes/g' $DIR/install-config.yaml
    openshift-install create manifests --dir=$DIR
    patch $DIR/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch
    cp $DIR/manifests/cluster-network-02-config.yml $DIR/manifests/cluster-network-03-config.yml
    sleep 1s
    patch $DIR/manifests/cluster-network-03-config.yml backups/cluster-network-03-config.patch
    echo "Patching Complete Preparing to install"
    openshift-install create cluster --dir=$DIR
    echo "Install is completed"
    export KUBECONFIG=$PREWD/$DIR/auth/kubeconfig
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
