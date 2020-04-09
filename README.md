Tooling to automate the steps to deploy openshift with OVN-Hybred Networking to Azure Only.
Example steps
git clone this repo
cd deploymentTooling
./nightlyTools.sh 4.4.0-0.nightly-2020-04-03-223145
make a install directoy
mkdir azure
./installWithOVNHybrid.sh azure/
follow prompts
