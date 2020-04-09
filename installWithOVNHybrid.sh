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

    #Store the InfraID for future use
    INFRAID="$(jq -r .infraID $1/metadata.json)"

    MYIP="$(curl ifconfig.me)"
    echo "Setup firewall Rules for network and for $MYIP to use ansivle"
    az network nsg rule create -g $INFRAID-rg --nsg-name $INFRAID-node-nsg -n WinRMHTTPS --priority 510 --source-address-prefixes 40.122.148.16 --destination-port-ranges 5986
    az network nsg rule create -g $INFRAID-rg --nsg-name $INFRAID-node-nsg -n AllLocalWorker --priority 520 --source-address-prefixes 10.0.0.0/16 --destination-port-ranges 0-65535
    #TODO Automate the process of Deployment via a templete here
    NODENAME="winnode"$(date +%d%H%M%S)""
    PASSWD="$(openssl rand -base64 20)"
    az group create--resource-group $INFRAID-rg
    az deployment group create \
      --name ExampleDeployment \
      --resource-group ExampleGroup \
      --template-file storage.json \
      --parameters storageAccountType=Standard_GRS
    #TODO Run Powershell commands here to enable Ansible
    #NODEIP="$(az vm list-ip-addresses -g gmarkley-fnmpq-rg -n $NODENAME | jq -r '.[] | .virtualMachine.network.publicIpAddresses | .[] | .ipAddress')"
    #create the hosts file need a config file for this.
    #az vm run-command invoke --command-id RunPowerShellScript --name $NODENAME -g $INFRAID-rg --scripts backups/ansibleSetupPS
    #az vm run-command invoke --command-id RunPowerShellScript --name $NODENAME -g $INFRAID-rg --scripts backups/loggingSetupPS

    echo "Setup WMCB"
    #git clone https://github.com/openshift/windows-machine-config-bootstrapper.git
    #sed -i '328c\      shell: "echo $NODENAME"' windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml

    echo "Create hosts file"
    #TODO combine createHostsFile.sh here
    #Ansible Commands here down
    echo "Ansible boot strap the windows node"
    echo "ansible win -i hosts -m win_ping -v"
    echo "ansible-playbook -i hosts windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml -v"
  fi
else
  echo "Install directory not supplied."
fi
