#!/bin/bash -i

if [ -n "$1" ]; then
  cd tools || exit
  rm -rf *
  wget $1/openshift-install-linux.tar.gz
  wget $1/openshift-client-linux.tar.gz
  tar -xzvf openshift-install-linux.tar.gz
  tar -xzvf openshift-client-linux.tar.gz
else
  echo "Download URL parameter not supplied. Please provide a URL to installer and client directory. Example: https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.4.0/"
fi