#!/bin/bash

# Resets the postgres table sequences so that they align with data which has
# been inserted whilst specifying the tables primary key.

ENVIRONMENT="$1"

echo "Resetting sequences"
reset_commands=(
  "SELECT SETVAL('public.conditions_id_seq', COALESCE(MAX(id), 1) ) FROM public.conditions;"
  "SELECT SETVAL('public.forms_id_seq', COALESCE(MAX(id), 1) ) FROM public.forms;"
  "SELECT SETVAL('public.made_live_forms_id_seq', COALESCE(MAX(id), 1) ) FROM public.made_live_forms;"
  "SELECT SETVAL('public.pages_id_seq', COALESCE(MAX(id), 1) ) FROM public.pages;"
  "SELECT SETVAL('public.versions_id_seq', COALESCE(MAX(id), 1) ) FROM public.versions;"
)

for command in "${reset_commands[@]}"; do
  echo "Running: ${command}"
  aws-vault exec "${ENVIRONMENT}-support" -- forms data_api -d forms-api -s "${command}"
done
