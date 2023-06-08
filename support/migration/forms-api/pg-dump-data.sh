#!/bin/bash

# Uses cf conduit to apply pg_dump to create an extract of forms-api database
# without the access_tokens table.

ENVIRONMENT="$1"
TIME_STAMP="$(date +%s)"
EXTRACT_FILE_NAME="${TMPDIR}/forms-api-paas-${ENVIRONMENT}-${TIME_STAMP}"

echo "Extracting data from forms-api"
cf services
cf conduit "forms-api-${ENVIRONMENT}-db" -- pg_dump \
  -O \
  --data-only \
  --no-comments \
  --on-conflict-do-nothing \
  --rows-per-insert=1 \
  --column-inserts \
  --exclude-table access_tokens \
  -f "$EXTRACT_FILE_NAME"

echo "Copy the SQL from the extract into the AWS RDSquery editor and check the output"
echo "cat ${EXTRACT_FILE_NAME} | pbcopy"
