#! /usr/bin/env bash

##
# This script is a temporary measure to help us migrate resources between
# Terraform deployments in a controlled manner that doesn't require destroying
# any of them.
#
# Specifically we're targetting the IAM roles and policies created in the
# "engineers_access" module. We need to script this operation for a combination
# of two reasons
#
# 1. Different resources are created by the module depending on the environment
#    being targetted
# 2. Terraform must know precisely what it's going to be importing, and the
#    import statements used for that cannot be dynamic
#
# The script will read the relevant resources from a Terraform state file and
# produce am "imports.tf" file with all the imports declared. Without that file,
# Terraform will recreate the IAM roles and policies and probably fail to do so.
#
# After we've run the imports across every environment once, we can get rid of this
# script and continue on to treat it like any other piece of Terraform
##

STATE_FILE="${1}"

if [ -z "${STATE_FILE}" ]; then
    echo "Usage: $0 <state_file>"
    echo ""
    cat <<EOF
The state file should be that of the 'engineers_access' root in an existing GOV.UK Forms deployment
EOF
    exit 1
fi

jq -r -f import-statements.jq "${STATE_FILE}" | terraform fmt - > imports.tf

echo ""
echo "Import statements written to imports.tf"
echo "imports.tf is ignored by .gitignore and shouldn't be checked in"
echo ""
cat <<EOF
To import these resources the new account state file, do the following

1. terraform init -backend-config tfvars/backends/ACCOUNT.tfvars
2. terraform apply -var-file tfvars/ACCOUNT.tfvars
3. Check the plan has no import failures and won't delete anything
4. Approve the plan and let Terraform carry it out

where ACCOUNT is the name of the account you are applying the changes to

Once Terraform as been run with the imports once in the account, the imports
file is no longer needed and can be removed. 
EOF

