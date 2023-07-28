#!/bin/bash
set -e

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo "
  Update the basic auth username and password and redeploy forms-admin in the
  user-research environment.

  You will need admin permission in the user-research AWS account and be
  connected to the VPN.

  Usage:
     $0 new-username new-password

     Example:
     ${0} 'user' 'top-secret'
   "
  exit 0
fi

if ! command -v jq &> /dev/null; then
  echo "Install 'jq' before proceeding. Using brew run:
  brew install jq
  "
  exit 1
fi

NEW_USERNAME="$1"
NEW_PASSWORD="$2"

echo "Updating username"
gds-cli aws forms-user-research-admin -- \
  aws ssm put-parameter \
    --type SecureString \
    --name "/forms-admin-user-research/basic-auth/username" \
    --value "${NEW_USERNAME}" \
    --overwrite

echo "Updating password"
gds-cli aws forms-user-research-admin -- \
  aws ssm put-parameter \
    --type SecureString \
    --name "/forms-admin-user-research/basic-auth/password" \
    --value "${NEW_PASSWORD}" \
    --overwrite

echo "Redeploying forms-admin"
gds-cli aws forms-user-research-admin -- \
  aws ecs update-service \
  --service "forms-admin" \
  --cluster "forms-user-research" \
  --force-new-deployment \
  --no-cli-pager > /dev/null

echo "Redeploy instruction sent. Wait for update to finish"
gds-cli aws forms-user-research-admin -- \
  ../../infra/modules/code-build-deploy-ecs/scripts/wait-for-deploy.sh "forms-admin" "forms-user-research"

