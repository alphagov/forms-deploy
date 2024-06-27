#!/usr/bin/env bash

if [ "${TF_VAR_apply_immediately:=false}" == true ]; then
    echo "Database changes will be applied immediately"
else
    echo "Database changes will be applied at the next maintenance window"
    echo "To apply changes immediately, set the environment variable 'TF_VAR_apply_immediately' to 'true'"
fi