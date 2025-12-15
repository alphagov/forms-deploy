#!/usr/bin/env bash
set -euo pipefail

environment="${2?Environment argument missing}"
src_dir="${3?Source directory argument missing}"

outputs=$(terraform -chdir="${src_dir}" output -json)
mapfile -t apply_projects < <(echo "$outputs" | jq -r '.terraform_apply_projects.value[]')
cache_bucket=$(echo "$outputs" | jq -r '.provider_cache_bucket_name.value')
cache_namespace=$(echo "$outputs" | jq -r '.provider_cache_namespace.value')

cache_config="$(jq -nc --arg bucket "${cache_bucket}" --arg namespace "${cache_namespace}" '{type: "S3", location: $bucket, cacheNamespace: $namespace}')"

echo "Checking '${environment}-apply-*' CodeBuild projects for missing cache namespace..."

# Get current project details
projects_json=$(aws codebuild batch-get-projects --names "${apply_projects[@]}")

# Filter to only projects missing cacheNamespace
mapfile -t projects_to_update < <(echo "$projects_json" | jq -r '.projects[] | select(.cache.cacheNamespace == null or .cache.cacheNamespace == "") | .name')

if [ "${#projects_to_update[@]}" -eq 0 ]; then
    echo "All '${environment}-apply-*' CodeBuild projects already have cache namespace configured"
else
    echo "Updating cache namespace for projects: ${projects_to_update[*]}"

    for project in "${projects_to_update[@]}"; do
        aws codebuild update-project \
            --name "$project" \
            --cache "$cache_config" \
            >/dev/null
    done

    echo "Updated CodeBuild projects to use provider cache bucket ${cache_bucket} with namespace ${cache_namespace}"
fi
