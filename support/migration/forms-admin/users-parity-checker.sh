#!/bin/bash
set -x
ENVIRONMENT="$1"
TIME_STAMP="$(date +%s)"

PAAS_USERS="${TMPDIR}paas-users-${ENVIRONMENT}-${TIME_STAMP}"
AWS_USERS="${TMPDIR}aws-users-${ENVIRONMENT}-${TIME_STAMP}"

forms data_api --database forms-admin -s 'select * from users;' > ${AWS_USERS}

cf conduit forms-admin-${ENVIRONMENT}-db -- psql \
  -qAtX \
  -c 'select json_agg(users) from users;' \
  > ${PAAS_USERS}

echo 'Comparing Users tables...'
diff <(jq --sort-keys '.[]' ${PAAS_USERS}) <(jq --sort-keys '.records[] | (.created_at, .updated_at) |= gsub(" "; "T")' "${AWS_USERS}")
if [[ $? == 0 ]]; then
  echo "Users tables match"
fi