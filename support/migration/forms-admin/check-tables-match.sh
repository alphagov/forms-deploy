#!/bin/bash
set -eou pipefail

ENVIRONMENT="$1"
TIME_STAMP="$(date +%s)"

PAAS_TABLE="${TMPDIR}paas-table-${ENVIRONMENT}-${TIME_STAMP}"
AWS_TABLE="${TMPDIR}aws-table-${ENVIRONMENT}-${TIME_STAMP}"

tables=("organisations" "form_submission_emails" "users")

for table in "${tables[@]}"; do
  echo "Reading ${table} tables..."
  forms data_api --database forms-admin -s "SELECT * FROM ${table};" > ${AWS_TABLE}
  
  cf conduit forms-admin-${ENVIRONMENT}-db -- psql \
    -qAtX \
    -c "SELECT json_agg(${table}) FROM ${table};" \
    > ${PAAS_TABLE}


  echo "Comparing ${table} tables..."
  diff <(jq --sort-keys '.[]' ${PAAS_USERS}) \
    <(jq --sort-keys '.records[] | (.created_at, .updated_at) |= gsub(" "; "T")' \
    "${AWS_USERS}")
  if [[ $? == 0 ]]; then
    echo "${table} tables match!"
  else
    echo "${table} tables do not match"
  exit 1
  fi
done

echo "All tables match!"
