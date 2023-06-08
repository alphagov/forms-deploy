#!/bin/bash

# Clears necessary tables in AWS forms-admin database before migration.
tables=("users" "form_submission_emails" "organisations")

echo "Clearing out records for forms-admin in AWS"
for table in "${tables[@]}"; do
  echo "Deleting records in ${table}"
  forms data_api -d forms-admin -s "DELETE FROM ${table};"
done
