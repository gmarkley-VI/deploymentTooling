#!/bin/bash

if [ -n "$1" ]; then
  if [ -f tools ]; then
    rm -rf tools
    NEW=false
  else
    NEW=true
  fi
  mkdir tools
  cd tools || exit
  wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-install-linux.tar.gz
  wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-client-linux.tar.gz
  tar -xzvf openshift-install-linux.tar.gz
  tar -xzvf openshift-client-linux.tar.gz
  if $NEW; then
    PREWD="$(pwd)"
      sudo ln -s $PREWD/oc /usr/local/bin/
      sudo ln -s $PREWD/openshift-install /usr/local/bin/
      sudo ln -s $PREWD/kubectl /usr/local/bin/
  fi
  cd ..
else
  echo "Nightly  parameter not supplied. Please provide a nightly string"
fi