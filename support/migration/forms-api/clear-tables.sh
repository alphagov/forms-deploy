#!/bin/bash

# Clears necessary tables in AWS forms-api database before migration.

tables=("conditions" "made_live_forms" "pages" "forms" "versions")

echo "Clearing out records for forms-api in AWS"
for table in "${tables[@]}"; do
  echo "Deleting records in ${table}"
  forms data_api -d forms-api -s "DELETE FROM ${table};"
done
