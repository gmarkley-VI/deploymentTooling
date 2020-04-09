#!/bin/bash -i

#create the config
if [ -n "$1" ]; then
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
    oc get network.operator cluster -o yaml
    #./wni azure create --kubeconfig $1/auth/kubeconfig --credentials ~/.azure/osServicePrincipal.json --image-id MicrosoftWindowsServer:WindowsServer:2019-Datacenter-with-Containers:latest --instance-type Standard_D2s_v3 --dir $1
    echo "Create windows worker and RDP into Windows node and setup ansible"
    echo "Create hosts file"
    echo "Ansible boot strap the windows node"
    echo "ansible win -i hosts -m win_ping -v"
    echo "ansible-playbook -i hosts windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml -v"
  fi
else
  echo "Install directory not supplied."
fi
