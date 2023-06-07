#!/bin/bash

# Migrates the forms-api database from PaaS to AWS for a given environment.
# It outputs a pgdump file. The contents have to be manually copied to the AWS RDS Query editor for the corresponding RDS instance.

# Requires
# - forms-cli installed and using the alias "forms"
# - using an authenticated shell for the AWS account you need (via gds-cli or aws-vault)

if [ $# -eq 0 ]; then
    >&2 echo "No ENVIRONMENT set"
    exit 1
fi

if [[ "$(cf target)" =~ "FAILED" ]]; then
    exit 1
fi

ENVIRONMENT="$1"
ORG="gds-govuk-forms"
SPACE="forms-api-${ENVIRONMENT}"

target_paas=$(cf target -o "${ORG}" -s "${SPACE}")

echo "Clearing ${ENVIRONMENT} and generating pg_dump"
./clear-tables.sh
./reset-table-sequences.sh
./pg-dump-data.sh ${ENVIRONMENT}

read -r -p "Once SQL has been run via the AWS RDS Query editor press ENTER or ctl-C to quit"

echo "continuing"

# The order in the tables matters because we rely on the primary keys to identify the forms.
./reset-table-sequences.sh

