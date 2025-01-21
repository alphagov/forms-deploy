#!/usr/bin/env bash

set -e -u -o pipefail

VAR_FILE="${1}"

if [ -z "${VAR_FILE}" ]; then
    echo "Usage: $0 <account terraform vars file>"
    echo ""
    cat <<EOF
The vars should come from ../tfvars/backends and should contain the name of the
bucket which should be created and subsequently store the state file.

If you are starting a brand new account you will need to create a new file.
EOF
fi

EXPECTED_BUCKET_NAME=$(awk -F "=" '/bucket/ {print $2}' "${VAR_FILE}" | tr -d ' "')
EXPECTED_DYNAMO_DB_TABLE=$(awk -F "=" '/dynamodb_table/ {print $2}' "${VAR_FILE}" | tr -d ' "')
LOCAL_STATE_FILE_NAME="${EXPECTED_BUCKET_NAME}__state-bucket.tfstate"
REMOTE_STATE_FILE_NAME="state-bucket.tfstate"

echo "Reading from vars file ${VAR_FILE}"
echo "Bucket name: ${EXPECTED_BUCKET_NAME}"
echo "DynamoDB table name: ${EXPECTED_DYNAMO_DB_TABLE}"

if aws s3api head-bucket --bucket "${EXPECTED_BUCKET_NAME}"; then
    echo "Bucket already exists"

    if aws s3api head-object --bucket "${EXPECTED_BUCKET_NAME}" --key "${REMOTE_STATE_FILE_NAME}"; then
        echo "State file already exists. Downloading it in case there are changes."
        aws s3 cp "s3://${EXPECTED_BUCKET_NAME}/state-bucket.tfstate" "${LOCAL_STATE_FILE_NAME}"
    else
        echo "State file did not already exist. Will upload the new one afterwards."
    fi
fi

terraform init -upgrade
terraform apply \
  -var "bucket_name=${EXPECTED_BUCKET_NAME}" \
  -var "dynamodb_table=${EXPECTED_DYNAMO_DB_TABLE}" \
  -state "${LOCAL_STATE_FILE_NAME}"

BUCKET_NAME="$(terraform output -state "${LOCAL_STATE_FILE_NAME}" -raw "bucket_name")"

echo "Uploading state file to s3://${BUCKET_NAME}/${REMOTE_STATE_FILE_NAME}"
aws s3 cp "${LOCAL_STATE_FILE_NAME}" "s3://${BUCKET_NAME}/${REMOTE_STATE_FILE_NAME}"
