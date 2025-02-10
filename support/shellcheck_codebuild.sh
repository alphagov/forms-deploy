#!/usr/bin/env bash

set -e

search_dir="$(pwd)"

while IFS= read -r -d '' buildspec
do
  pushd "$(mktemp -d)" >/dev/null || exit
    file="${buildspec//\//_}"
    touch "${file}"
    yq '.phases|to_entries|.[]|select(.value|has("commands"))|.value.commands|.[]' "${buildspec}" > "${file}"
    shellcheck -s bash "${file}"
  popd >/dev/null || exit
done <  <(find "${search_dir}" -type f \( -name "buildspec.yml" -or -name "buildspec.yaml" \) -print0)
