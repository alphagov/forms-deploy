#!/bin/bash
set -eou pipefail

# Migrates the forms-api database from PaaS to AWS for a given environment (inferred from the AWS account you're logged into).
# It outputs a pgdump file. The contents have to be manually copied to the AWS RDS Query editor for the corresponding RDS instance.
# It checks that the content of the two databases match.

# Requires
# - forms-cli installed and using the alias "forms"
# - using an authenticated shell for the AWS account you need (via gds-cli or aws-vault)
# - be logged into PaaS London

if [ $# -lt "2" ]; then
        echo "Usage:  $0 <FORMS_API_AWS_KEY> <FORMS_API_PAAS_KEY>"
        exit 1;
fi

FORMS_API_AWS_KEY=$1
FORMS_API_PAAS_KEY=$2


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
SPACE="forms-api-${ENVIRONMENT}"

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

cf target -o "${ORG}" -s "${SPACE}"

echo "Clearing ${ENVIRONMENT} and generating pg_dump"
./clear-tables.sh
./reset-table-sequences.sh
./pg-dump-data.sh ${ENVIRONMENT}

read -r -p "Once SQL has been run via the AWS RDS Query editor press ENTER or ctl-C to quit"

echo "continuing"

# The order in the tables matters because we rely on the primary keys to identify the forms.
./reset-table-sequences.sh

# Check that the data is the same in both databases
ruby form-parity-checker.rb ${ENVIRONMENT} ${FORMS_API_AWS_KEY} ${FORMS_API_PAAS_KEY}
