#!/bin/bash
set -eou pipefail

# Migrates the forms-admin database from PaaS to AWS for a given environment.
# It outputs a pgdump file. The contents have to be manually copied to the AWS RDS Query editor for the corresponding RDS instance.

# Requires
# - forms-cli installed and using the alias "forms"
# - using an authenticated shell for the AWS account you need (via gds-cli or aws-vault)
# - be logged into PaaS London

if [[ "$(cf target)" =~ "FAILED" ]]; then
    exit 1
fi

aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text)

case "$aws_account_id" in
    '498160065950')
      ENVIRONMENT="dev"
      ;;
    '972536609845')
      ENVIRONMENT="staging"
      ;;
    '443944947292')
      ENVIRONMENT="production"
      ;;
    '619109835131')
      echo "You're in the user-research account. We don't have one in PaaS so there's nothing to do here."
      exit 1
      ;;
    *)
      echo "Unknown AWS account"
      exit 1
      ;;
esac

if [[ "$(cf target)" =~ "FAILED" ]]; then
    exit 1
fi

ORG="gds-govuk-forms"
SPACE="forms-admin-${ENVIRONMENT}"

read -rep "You will use the AWS account: ${ENVIRONMENT} | PaaS space: ${SPACE}. \
 Would you like to continue? (y/n): " yn
case $yn in
  [Yy]* )
  ;;
  * )
    echo "Quitting"
    exit;;
esac

if [[ $ENVIRONMENT == "production" ]]; then
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

read -rep "Would you like to check that the tables match? (y/n): " yn
case $yn in
  [Yy]* )
  ./check-tables-match.sh ${ENVIRONMENT};;
  * )
    echo "Quitting"
    exit;;
esac
