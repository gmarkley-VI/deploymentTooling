# Automate the steps to deploy openshift

OVN-Hybrid Networking and Azure Only.
***
  Example steps

    #git clone this repo
    cd deploymentTooling
    ./nightlyTools.sh 4.4.0-0.nightly-2020-04-03-223145
    #make a install dir
    mkdir azure
    ./installWithOVNHybrid.sh azure/
    #follow prompts
    #Once a cluster is setup then add a windows node
    ./installWindowsNode.sh azure/
