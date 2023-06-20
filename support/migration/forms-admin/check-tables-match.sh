#!/bin/bash
set -ou pipefail

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


  echo -e "\nComparing ${table} tables..."
  diff --side-by-side \
    <(jq --sort-keys '. | sort_by(.id)[]' ${PAAS_TABLE}) \
    <(jq --sort-keys '.records | sort_by(.id)[] | (.created_at, .updated_at) |= gsub(" "; "T")' \
    "${AWS_TABLE}")
  if [[ $? == 0 ]]; then
    echo -e "${table} tables match!\n"
  else
    echo -e "${table} tables do not match\n"
  fi

done