#!/usr/bin/env bash
##
# This script is run by invoke-terraform.sh before `terraform apply` is called in this directory.
# It gives useful information about when the RDS changes will be applied, and how to influence it.
##

if [ "${TF_VAR_apply_immediately:=false}" == true ]; then
    echo "Database changes will be applied immediately"
else
    echo "Database changes will be applied at the next maintenance window"
    echo "To apply changes immediately, set the environment variable 'TF_VAR_apply_immediately' to 'true'"
fi