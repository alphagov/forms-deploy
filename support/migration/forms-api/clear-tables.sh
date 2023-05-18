#!/bin/bash

# Clears necessary tables in AWS forms-api database prior to migration.
ENVIRONMENT="$1"

tables=("conditions" "made_live_forms" "pages" "forms" "versions")

echo "Clearing out records for forms-api in development"
for table in "${tables[@]}"; do
  echo "Deleting records in ${table}"
  aws-vault exec "${ENVIRONMENT}-support" -- forms data_api -d forms-api -s "DELETE FROM ${table};"
done
