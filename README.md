# Automate the steps to deploy openshift

OVN-Hybrid Networking and Azure Only.
***
###Pre-Reqs - Fedora 
(Not commands could be slightly different for your system)
  
    sudo dnf install python3 python3-libselinux jq git
    pip install ansible==2.9 pywinrm selinux --user
    
###Install Azure CLI and login

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
  
  Example steps

  * git clone this repo

Select your nightly install to use
https://openshift-release.svc.ci.openshift.org/


    cd deploymentTooling
    ./nightlyTools.sh 4.4.0-0.nightly-2020-04-03-223145

Install a cluster. You will want to use a directory as shown. You will also need to get your pull secret here https://cloud.redhat.com/openshift/install/azure/installer-provisioned

    mkdir azure
    ./installOSAzureOVNHybrid.sh azure/
    #follow prompts
    
Install a Windows Node
    
    ./installWindowsNode.sh azure/
