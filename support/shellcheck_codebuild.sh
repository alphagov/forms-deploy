#!/usr/bin/env bash

set -euo pipefail

search_dir="$(pwd)"
result=0

while IFS= read -r -d '' buildspec
do
  pushd "$(mktemp -d)" >/dev/null || exit
    file="${buildspec//\//_}"
    touch "${file}"
    yq '.phases|to_entries|.[]|select(.value|has("commands"))|.value.commands|.[]' "${buildspec}" > "${file}"
    echo "Checking ${buildspec#"${search_dir}/"}"



    if shellcheck -s bash "${file}";
    then
      echo "OK ${buildspec#"${search_dir}/"}"
      # errors are written to stdout and are obvious
    else
      result=1
    fi

  popd >/dev/null || exit
done <  <(find "${search_dir}" -type f \( -name "buildspec.yml" -or -name "buildspec.yaml" -or -path "*/buildspecs/*.yml" -or -path "*/buildspecs/*.yaml" \) -print0)

exit $result
