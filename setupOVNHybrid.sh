#!/bin/bash -i

#create the config
if [ -n "$1" ]; then
  if [ ! -f $1/install-config.yaml ]; then
    echo "openshift-install create install-config --dir=$1"
    openshift-install create install-config --dir=$1
    echo "sed -i 's/OpenShiftSDN/OVNKubernetes/g' $1/install-config.yaml"
    sed -i 's/OpenShiftSDN/OVNKubernetes/g' $1/install-config.yaml
    echo "openshift-install create manifests --dir=$1"
    openshift-install create manifests --dir=$1
    echo "patch $1/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch"
    patch $1/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch
    echo "cp backups/cluster-network-03-config.yml $1/manifests/."
    cp backups/cluster-network-03-config.yml $1/manifests/.
    echo "Patching Complete Preparing to install"
    echo "openshift-install create cluster --dir=$1"
    openshift-install create cluster --dir=$1
    echo "Install is completed"
    export KUBECONFIG=/home/gmarkley/azureTest/auth/kubeconfig
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
