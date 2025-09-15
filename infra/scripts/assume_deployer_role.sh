#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed directly"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: source assume_deployer_role.sh <environment>"
    return 1
fi

ENVIRONMENT=$1

account_id=$(aws sts get-caller-identity --query Account --output text)
role_arn="arn:aws:iam::${account_id}:role/deployer-${ENVIRONMENT}"

echo "Assuming role ${role_arn}"
creds=$(aws sts assume-role --role-arn "${role_arn}" --role-session-name "DeployerSession" --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text)

export AWS_ACCESS_KEY_ID=$(echo "$creds" | awk '{print $1}')
export AWS_SECRET_ACCESS_KEY=$(echo "$creds" | awk '{print $2}')
export AWS_SESSION_TOKEN=$(echo "$creds" | awk '{print $3}')
