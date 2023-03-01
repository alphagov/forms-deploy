#!/bin/bash

DATA_BASE="$1"
STATEMENT="$2"

echo 'This is defunct. Use the forms-cli instead'

function usage() {
  echo "
  Executes the provided SQL statement against the specified database.

  Usage:
     Run in a authorized shell using gds-cli or aws-vault
     $0 data-base sql-statement

     data-base, the database to execute the statement upon [forms-api | forms-admin]
     sql-statement, the statement to execute

     Example:
     aws-vault exec dev-admin -- ${0} forms-api 'SELECT * FROM forms'"
  exit 0
}

if [[ -z "$DATA_BASE" ]] || [[ -z "$STATEMENT" ]] || [[ "$1" == "help" ]]; then
  usage
fi

if [ "$DATA_BASE" != "forms-api" ] && [ "$DATA_BASE" != "forms-admin" ]; then
  echo "Database must be either 'forms-api' or 'forms-admin'."
  usage
fi

read -rep $'Warning: This can execute write statements. Enter y to continue:\n' yn
case $yn in
  [^Yy]*)
    echo "Quitting"
    exit;;
esac

function get_aws_account_id() {
  aws sts get-caller-identity \
    --query Account \
    --output text
}

function is_production() {
  [ 443944947292 -eq "$(get_aws_account_id)" ]
}

if is_production; then
  read -rep $'Running against production. Enter y to continue:\n' yn
  case $yn in
    [^Yy]*)
      echo "Quitting"
      exit;;
  esac
fi

function get_login_secret_arn() {
  aws secretsmanager list-secrets \
    --filter Key="all",Values="${DATA_BASE}-app" \
    --output text \
    --query SecretList[0].ARN
}

function get_rds_cluster_arn() {
  aws rds describe-db-clusters \
    --output text \
    --query DBClusters[0].DBClusterArn
}

aws rds-data execute-statement \
  --resource-arn "$(get_rds_cluster_arn)" \
  --secret-arn "$(get_login_secret_arn)" \
  --database "$DATA_BASE" \
  --sql "$STATEMENT" \
  --format-records-as JSON \
  | jq '.formattedRecords |= fromjson'

