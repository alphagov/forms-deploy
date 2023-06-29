#!/bin/bash
#
# Script to compare enviornment variables set on PaaS with those set in AWS.
# First log into PaaS and then run in an shell authenticated for the target AWS
# environment, e.g.
#
# aws-vault exec staging-support -- ./check.sh

if [[ "$(cf target)" =~ "FAILED" ]]; then
  echo 'Log into PaaS first'
  exit 1
fi

function aws_vars() {
  local app="$1"
  local environment="$2"

  aws ecs describe-task-definition \
    --task-definition "${environment}_forms-${app}" \
    | jq -r '.taskDefinition.containerDefinitions[] | .environment + .secrets | .[] | "\(.name): \(.value)"' \
    | sort
}

function paas_target() {
  local app="$1"
  local environment="$2"
  cf t -s "forms-${app}-${environment}" > /dev/null || exit 1
}

function paas_vars() {
  local app="$1"
  local environment="$2"

  cf env "forms-${app}-${environment}" \
    | grep -e "[A-Z]\+:" | grep -v 'VCAP' \
    | sort
}

aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text)

case "$aws_account_id" in
    '498160065950')
      ENVIRONMENT="dev"
      ;;
    '972536609845')
      ENVIRONMENT="staging"
      ;;
    '443944947292')
      ENVIRONMENT="production"
      ;;
    '619109835131')
      echo "You're in the user-research account. We don't have one in PaaS so there's nothing to do here."
      exit 1
      ;;
    *)
      echo "Unknown AWS account"
      exit 1
      ;;
esac

echo "Checking env vars in ${ENVIRONMENT}"

for app in api admin runner; do
  echo "$app"
  echo "------"
  paas_target "$app" "$ENVIRONMENT"

  diff -y <(aws_vars "$app" "$ENVIRONMENT") <(paas_vars "$app" "$ENVIRONMENT")
done

