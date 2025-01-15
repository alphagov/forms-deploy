#!/usr/bin/env bash

##
# This script is run by invoke-terraform.sh before `terraform init` is called in this directory.
# It prevents us trying to use this root in the 'deploy' account
##

environment="${2}"

if [[ "${environment}" == "deploy" ]]; then
  echo "The 'deploy' environment has its own 'account' root module. To configure it, use the 'deploy/account' root"
  exit 2
fi