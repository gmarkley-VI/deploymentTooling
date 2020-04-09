#!/bin/bash

if [ -n "$1" ]; then
  if [ -f tools ]; then
    rm -rf tools
    mkdir tools
    cd tools || exit
    wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-install-linux.tar.gz
    wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-client-linux.tar.gz
    tar -xzvf openshift-install-linux.tar.gz
    tar -xzvf openshift-client-linux.tar.gz
    cd ..
  else
    mkdir tools
    cd tools || exit
    wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-install-linux.tar.gz
    wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-client-linux.tar.gz
    tar -xzvf openshift-install-linux.tar.gz
    tar -xzvf openshift-client-linux.tar.gz
    cd ..
    ##TODO - Setup first time run here
    #Print out the ln -s for the /lib/bin here if its first time run
  fi
else
  echo "Nightly  parameter not supplied. Please provide a nightly string"
fi