#!/bin/bash

if [ -n "$1" ]; then
	rm -rf tools
	mkdir tools
	cd tools
	wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-install-linux.tar.gz
	wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/$1/openshift-client-linux.tar.gz
	tar -xzvf openshift-install-linux.tar.gz
	tar -xzvf openshift-client-linux.tar.gz
	cd ..
else
  echo "Nightly  parameter not supplied. Please provide a nightly string"
fi