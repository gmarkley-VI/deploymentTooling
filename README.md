## Archive this is an old project

# Steps to deploy

OVN-Hybrid Networking
*** 
###Install OCP with OVN Hybrid

Example steps

  * git clone this repo

Select your nightly install to use
https://openshift-release.svc.ci.openshift.org/


    cd deploymentTooling
    ./nightlyTools.sh 4.4.0-0.nightly-2020-04-03-223145

Install a cluster. You will want to use a directory as shown. You will also need to get your pull secret here https://cloud.redhat.com/openshift/install/azure/installer-provisioned

    mkdir azure
    ./installOSOVNHybrid.sh azure/
    #follow prompts
