#!/bin/bash
set -e

if ! command -v chromedriver &> /dev/null; then
  echo "Install chromedriver, see forms-deploy/capybara/README.md"
  exit 1
fi

environment="$1"

if [[ -z "$environment" ]] || [[ "$1" == "help" ]] || [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "Runs the Capybara end-to-end tests for the given environment.

Run in an authenticated shell with permission to access ssm params in
forms-deploy using the gds-cli or aws-vault

Usage: $0 dev|staging|paas_dev|paas_staging

Example:
gds-cli aws forms-deploy-readonly -- $0 dev
"
  exit 0
fi

function admin_url() {
  case $environment in
    "paas_dev") echo "https://forms-admin-dev.london.cloudapps.digital" ;;
    "paas_staging") echo "https://forms-admin-staging.london.cloudapps.digital" ;;
    "paas_production") echo "https://forms-admin-prod.london.cloudapps.digital" ;;
    "dev") echo "https://admin.dev.forms.service.gov.uk" ;;
    "staging") echo "https://admin.staging.forms.service.gov.uk" ;;
    "production") echo "https://admin.forms.service.gov.uk" ;;
    *)
      echo "Unknown environment: ${environment}"
      exit 1
      ;;
  esac
}

function get_param() {
  path="$1"

  aws ssm get-parameter \
    --with-decrypt \
    --name "$path" \
    --output text \
    --query 'Parameter.Value'
}

if [[ "$(admin_url)" =~ "Unknown" ]]; then
    exit 1
fi

export FORMS_ADMIN_URL="$(admin_url)"
export SIGNON_USERNAME="$(get_param /${environment}/smoketests/${kind}/signon/username)"
export SIGNON_OTP="$(get_param /${environment}/smoketests/${kind}/signon/secret)"
export SIGNON_PASSWORD="$(get_param /${environment}/smoketests/${kind}/signon/password)"
export SETTINGS__GOVUK_NOTIFY__API_KEY="$(get_param /${environment}/smoketests/notify/api-key)"

cd ../../capybara
bundle install

bundle exec rspec
