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

    NODENAME="winnode"$(date +%d%H%M%S)""
    sed -i "30c\            \"value\": \"$NODENAME\"" template/parameters.json
    PASSWD="$(openssl rand -base64 20)"
    sed -i "45c\            \"value\": \"$PASSWD\"" template/parameters.json
    sed -i "33c\            \"value\": \"$INFRAID-rg\"" template/parameters.json
    sed -i "21c\            \"value\": \"$NODENAME-ip\"" template/parameters.json
    SUBSCRIPTID="$(az account list | jq -r '.[] | .id')"
    sed -i "18c\            \"value\": \"/subscriptions/$SUBSCRIPTID/resourceGroups/$INFRAID-rg/providers/Microsoft.Network/virtualNetworks/$INFRAID-vnet\"" template/parameters.json
    sed -i "15c\            \"value\": \"$INFRAID-worker-subnet\"" template/parameters.json
    sed -i "12c\            \"value\": \"/subscriptions/$SUBSCRIPTID/resourceGroups/$INFRAID-rg/providers/Microsoft.Network/loadBalancers/$INFRAID/backendAddressPools/$INFRAID\"" template/parameters.json
    NUM=`echo $(( $RANDOM % 999 ))`
    sed -i "9c\            \"value\": \"$NODENAME$NUM\"" template/parameters.json
    LOCATION="$(az group show -n "$INFRAID-rg" | jq -r '.location')"
    sed -i "6c\            \"value\": \"$LOCATION\"" template/parameters.json

    sed -i "s/kubernetes.io-cluster-ID/kubernetes.io-cluster-$INFRAID" template/template.json

    az deployment group create \
      --name addWindowsNode \
      --resource-group $INFRAID-rg \
      --template-file template/template.json \
      --parameters template/parameters.json

    echo "Windows Node Added"
    NODEIP="$(az vm list-ip-addresses -g gmarkley-fnmpq-rg -n $NODENAME | jq -r '.[] | .virtualMachine.network.publicIpAddresses | .[] | .ipAddress')"
    #create the hosts file need a config file for this.
    az vm run-command invoke --command-id RunPowerShellScript --name $NODENAME -g $INFRAID-rg --scripts @backups/ansibleSetupPS
    az vm run-command invoke --command-id RunPowerShellScript --name $NODENAME -g $INFRAID-rg --scripts @backups/loggingSetupPS

    echo "Setup WMCB"
    git clone https://github.com/openshift/windows-machine-config-bootstrapper.git
    sed -i "328c\      shell: \"echo $NODENAME\"" windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml

    #create a hosts file
    cp backups/hosts .
    CURL=$(oc cluster-info | head -n1 | sed 's/.*\/\/api.//g'| sed 's/:.*//g')
    sed -i "s/<node_ip>/$NODEIP/g" hosts
    sed -i "s/<password>/\x27$PASSWD\x27/g" hosts
    sed -i "s/<username>/core/g" hosts
    sed -i "s/<cluster_address>/$CURL/g" hosts

    #Ansible Commands here down
    ansible win -i hosts -m win_ping -v
    ansible-playbook -i hosts windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml -v

    oc get nodes
  fi
else
  echo "Install directory not supplied."
fi
