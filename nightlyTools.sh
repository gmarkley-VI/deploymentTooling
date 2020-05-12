#!/bin/bash -i

if [ -n "$1" ]; then
  cd tools || exit
  rm -rf *
  wget $1/openshift-install-linux.tar.gz
  wget $1/openshift-client-linux.tar.gz
  tar -xzvf openshift-install-linux.tar.gz
  tar -xzvf openshift-client-linux.tar.gz
  PREWD="$(pwd)"
  if [ ! -f /usr/local/bin/oc ]; then
    sudo ln -s $PREWD/oc /usr/local/bin/
    echo "Setup: sudo ln -s $PREWD/oc /usr/local/bin/"
  fi
  if [ ! -f /usr/local/bin/openshift-install ]; then
    sudo ln -s $PREWD/openshift-install /usr/local/bin/
    echo "Setup: sudo ln -s $PREWD/openshift-install /usr/local/bin/"
  fi
  if [ ! -f /usr/local/bin/kubectl ]; then
    sudo ln -s $PREWD/kubectl /usr/local/bin/
    echo "Setup: sudo ln -s $PREWD/kubectl /usr/local/bin/"
  fi
  cd ..
  echo "oc, kubectl, openshift-install - nightly $1 installed and configured for use."
else
  echo "Download URL parameter not supplied. Please provide a URL to installer and client directory. Example: https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.4.0/"
fi