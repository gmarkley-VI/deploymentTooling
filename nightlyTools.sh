#!/bin/bash -i

if [ -n "$1" ] && [ -n "$2" ]; then
  cd tools || exit
  rm -rf *
  wget $1/openshift-install-$2.tar.gz
  wget $1/openshift-client-$2.tar.gz
  tar -xzvf openshift-install-$2.tar.gz
  tar -xzvf openshift-client-$2.tar.gz
else
  echo "Download URL parameter not supplied. Please provide a URL to installer and client directory. Example: https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.4.0/ format is ./nightlyTools.sh url os  where os is [linux,mac]"
fi