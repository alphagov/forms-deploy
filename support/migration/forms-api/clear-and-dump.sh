#!/bin/bash

# Migrates the forms-api database from PaaS to AWS for a given environment.
# It outputs a pgdump file. The contents have to be manually copied to the AWS RDS Query editor for the corresponding RDS instance.

# Requires
# - forms-cli installed and using the alias "forms"
# - using an authenticated shell for the AWS account you need (via gds-cli or aws-vault)

if [ $# -eq 0 ]; then
    >&2 echo "No ENVIRONMENT set. Valid values: dev, staging, production, user-research"
    exit 1
fi

if [[ "$(cf target)" =~ "FAILED" ]]; then
    exit 1
fi

ENVIRONMENT="$1"
ORG="gds-govuk-forms"
SPACE="forms-api-${ENVIRONMENT}"

aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text)

case "$aws_account_id" in
    '498160065950')
      aws_account="dev"
      ;;
    '972536609845')
      aws_account="staging"
      ;;
    '443944947292')
      aws_account="production"
      ;;
    '619109835131')
      aws_account="user-research"
      ;;
    *)
      echo "Unknown AWS account"
      exit 1
      ;;
esac

read -rep "You will use the AWS account: ${aws_account} | PaaS space: ${SPACE}. \
 Would you like to continue? (y/n): " yn
case $yn in
  [Yy]* )
  ;;
  * )
    echo "Quitting"
    exit;;
esac

if [[ $aws_account == "production" ]]; then
    read -rep "Are you sure? it's production! (y/n): " yn
    case $yn in
    [Yy]* ) echo "Good luck";;
    * )
        echo "Phew..."
        exit;;
    esac
fi

target_paas=$(cf target -o "${ORG}" -s "${SPACE}")

echo "Clearing ${ENVIRONMENT} and generating pg_dump"
./clear-tables.sh
./reset-table-sequences.sh
./pg-dump-data.sh ${ENVIRONMENT}

read -r -p "Once SQL has been run via the AWS RDS Query editor press ENTER or ctl-C to quit"

echo "continuing"

# The order in the tables matters because we rely on the primary keys to identify the forms.
./reset-table-sequences.sh

