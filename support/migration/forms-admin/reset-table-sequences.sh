#!/bin/bash

# Resets the postgres table sequences so that they align with data which has
# been inserted whilst specifying the tables primary key.

echo "Resetting sequences"
reset_commands=(
  "SELECT SETVAL('public.organisations_id_seq', COALESCE(MAX(id), 1) ) FROM public.organisations;"
  "SELECT SETVAL('public.form_submission_emails_id_seq', COALESCE(MAX(id), 1) ) FROM public.form_submission_emails;"
  "SELECT SETVAL('public.users_id_seq', COALESCE(MAX(id), 1) ) FROM public.users;"
)

for command in "${reset_commands[@]}"; do
  echo "Running: ${command}"
  forms data_api -d forms-admin -s "${command}"
done
