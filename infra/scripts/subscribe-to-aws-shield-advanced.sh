#!/bin/bash
# Explicitly not setting -e so that we can read exit codes safely
set -uo pipefail

echo "Checking AWS Shield subscription"
# Setting region to us-east-1 explicitly because Shield is a global service
aws --region us-east-1 shield describe-subscription > /dev/null 2>&1
IS_SUBSCRIBED_EXIT_CODE=$?

if [ $IS_SUBSCRIBED_EXIT_CODE -ne 0 ]; then
  echo "Subscription does not exist"
  echo "Creating AWS Shield subscription"

  if aws --region us-east-1 shield create-subscription; then
    echo "Subscription created."
  else
    echo "Failed to create subscription"
    exit 1
  fi
else
  echo "AWS Shield subscription exists"
fi
