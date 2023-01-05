#!/bin/bash

if [[ "$1" == "help" ]]; then
  echo "
  Returns SSM Parameters using aws ssm get-parameters-by-path.

  Usage:
     Run in a authorized shell using gds-cli or aws-vault
     $0 [parameter-path]

     parameter-path: optional ssm parameter path to filter. Must begin with '/'. Defaults to '/'

     Example:
     aws-vault exec dev-admin -- ${0} /forms-api-dev"
  exit 0
fi

SEARCH_PATH=${1-/}

aws ssm get-parameters-by-path \
  --with-decryption \
  --recursive \
  --path "${SEARCH_PATH}" \
  --query "Parameters[].[Name,Value]" \
  --output text \
| column -t

