#!/bin/bash

# Checks all buckets for a bucket policy statement named 'https_only'
function has_https_only_policy {
  aws s3api get-bucket-policy --bucket "$bucket" 2>/dev/null | jq '.Policy | fromjson | any(.Statement[]; .Sid == "https_only")'
}

for bucket in $(aws s3api list-buckets | jq '.Buckets[].Name' -r); do
  if [[ $(has_https_only_policy) == "true" ]]; then
    echo "${bucket} OK"
  else
    echo "${bucket} NO_HTTPS_ONLY_POLICY"
  fi
done
