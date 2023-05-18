#!/bin/bash
# This script uses the redis-cli to query redis on PaaS and print out the
# number of user sessions in progress. An in progress session is one where the
# key 'answers' is set and contains non-null values.
#
# Open a tunnel to the redis service on PaaS using cf conduit. The script
# takes the redis password as its first argument.

set -e

REDIS_PASSWORD="$1"
PORT="7080"

function query_redis {
  query="$1"

  redis-cli \
    -h localhost \
    -p "$PORT" \
    -a "${REDIS_PASSWORD}" \
    --no-auth-warning \
    --tls <<< "$query"
}

function count_in_progress_sessions {
  redis_data="$1"

  jq -s '[.[]
    | select(.answers!= null and (.answers | length) > 0).answers
    | to_entries
    | .[]
    | select(.value != null)]
    | length ' <<< "$redis_data"
}

# Check requirements
for command in redis-cli jq; do
  if ! command -v "$command" &> /dev/null; then
      echo "${command} could not be found."
      exit 1
  fi
done

if [ -z "$REDIS_PASSWORD" ]; then
  echo "usage $0 redis-password"
  exit 1
fi

# Query redis and print in progress sessions
session_keys="$(query_redis 'KEYS session*')"
if [ -z "$session_keys" ]; then
  echo "No sessions"
  exit 0
fi

get_values_command="$(sed 's/^/GET /' <<< "$session_keys")"
redis_data="$(query_redis "${get_values_command}")"

date
echo "In progress sessions:"
count_in_progress_sessions "$redis_data"
