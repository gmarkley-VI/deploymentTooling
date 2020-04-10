#!/bin/bash -i

if [ -n "$1" ]; then
  PREWD="$(pwd)"
  export KUBECONFIG=$PREWD/$1/auth/kubeconfig

  #Store the InfraID for future use
  INFRAID="$(jq -r .infraID $1/metadata.json)"

  MYIP="$(curl ifconfig.me)"
  echo "Setup firewall Rules for network and for $MYIP to use ansible"
  az network nsg rule create -g $INFRAID-rg --nsg-name $INFRAID-node-nsg -n WinRMHTTPS --priority 510 --source-address-prefixes 40.122.148.16 --destination-port-ranges 5986
  az network nsg rule create -g $INFRAID-rg --nsg-name $INFRAID-node-nsg -n AllLocalWorker --priority 520 --source-address-prefixes 10.0.0.0/16 --destination-port-ranges 0-65535

  echo "Configuring Paramaters"
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

  echo "Configuring Template"
  sed -i "s/kubernetes.io-cluster-ID/kubernetes.io-cluster-$INFRAID/g" template/template.json

  echo "Deploying $NODENAME via template"
  az deployment group create \
    --name addWindowsNode \
    --resource-group $INFRAID-rg \
    --template-file template/template.json \
    --parameters template/parameters.json

  echo "Windows Node Added waiting 2 min for it to boot"
  sleep 2m
  #TODO replace the above sleep with a check for status


  echo "Running PS scripts on host:$NODENAME"
  #create the hosts file need a config file for this.
  az vm run-command invoke --command-id RunPowerShellScript --name $NODENAME -g $INFRAID-rg --scripts @backups/ansibleSetupPS
  az vm run-command invoke --command-id RunPowerShellScript --name $NODENAME -g $INFRAID-rg --scripts @backups/loggingSetupPS

  echo "Setup WMCB"
  git clone https://github.com/openshift/windows-machine-config-bootstrapper.git
  sed -i "328c\      shell: \"echo $NODENAME\"" windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml

  NODEIP="$(az vm list-ip-addresses -g $INFRAID-rg -n $NODENAME | jq -r '.[] | .virtualMachine.network.publicIpAddresses | .[] | .ipAddress')"
  #TODO loop to make sure IP is there.

  #create a hosts file
  echo "Setup hosts file for $NODENAME at $NODEIP"
  cp backups/hosts .
  CURL=$(oc cluster-info | head -n1 | sed 's/.*\/\/api.//g'| sed 's/:.*//g')
  sed -i "2c\$NODEIP ansible_password=\"$PASSWD\"" hosts
  sed -i "s/<username>/core/g" hosts
  sed -i "s/<cluster_address>/$CURL/g" hosts

  #Ansible Commands here down
  echo "Test ansible connection"
  ansible win -i hosts -m win_ping -v
  echo "Running bootstapper via Ansible"
  ansible-playbook -i hosts windows-machine-config-bootstrapper/tools/ansible/tasks/wsu/main.yaml -v

  oc get nodes
else
  echo "Install directory not supplied."
fi