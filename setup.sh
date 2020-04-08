#!/bin/bash -i
INFILE=$1
#create the config
if [ ! -f $INFILE/install-config.yaml ]; then
  echo "openshift-install create install-config --dir=$INFILE"
  openshift-install create install-config --dir=$INFILE
  echo "sed -i 's/OpenShiftSDN/OVNKubernetes/g' $INFILE/install-config.yaml"
  sed -i 's/OpenShiftSDN/OVNKubernetes/g' $INFILE/install-config.yaml
  echo "openshift-install create manifests --dir=$INFILE"
  openshift-install create manifests --dir=$INFILE
  while [ ! -f $INFILE/manifests/cloud-provider-config.yaml ]; do sleep 1; done
  echo "patch $INFILE/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch"
  patch $INFILE/manifests/cloud-provider-config.yaml backups/cloud-provider-config.patch
  echo "cp backups/cluster-network-03-config.yml $INFILE/manifests/."
  cp backups/cluster-network-03-config.yml $INFILE/manifests/.
  echo "Patching Complete Preparing to install"
  echo "openshift-install create cluster --dir=$INFILE"
  openshift-install create cluster --dir=$INFILE
  echo "Install is completed"
  export KUBECONFIG=/home/gmarkley/azureTest/auth/kubeconfig
  #./wni azure create --kubeconfig $INFILE/auth/kubeconfig --credentials ~/.azure/osServicePrincipal.json --image-id MicrosoftWindowsServer:WindowsServer:2019-Datacenter-with-Containers:latest --instance-type Standard_D2s_v3 --dir $INFILE
  echo "Create wisndos worker and RDP into Windows node and setup ansible"
  echo "Create Hosts file"
  oc cluster-info | head -n1 | sed 's/.*\/\/api.//g'| sed 's/:.*//g'
  echo "Ansible boot strap the windos node"
  echo "ansible win -i hosts -m win_ping -v"
  echo "ansible-playbook -i hosts windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml -v"
fi