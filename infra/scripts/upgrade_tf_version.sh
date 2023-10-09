#!/usr/bin/env bash

__dir__=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if ! command -v tfenv >/dev/null; then
    echo "You must have tfenv installed"
    exit 1
fi

if ! command -v jq >/dev/null; then
    echo "You must have jq installed"
    exit 1
fi

current_version_constraint=$(sed -nr 's#.*required_version = "(.*)"#\1#p' "${__dir__}/../shared/versions.tf")
echo "Current version constraint: ${current_version_constraint}"

latest_version=$(curl -sL "https://api.github.com/repos/hashicorp/terraform/releases" | jq -rf "${__dir__}/latest-tf-release.jq" | tr -d 'v')
echo "Latest version: ${latest_version}"

major=$(echo "${latest_version}" | cut -d. -f1)
minor=$(echo "${latest_version}" | cut -d. -f2)
new_constraint="~>${major}.${minor}"

echo "Writing new version constraint '${new_constraint}'"
sed -r -i.bak "s%(.*)required_version = \"(.*)\"%\1required_version = \"${new_constraint}\"%g" "${__dir__}/../shared/versions.tf"
rm "${__dir__}/../shared/versions.tf.bak"

echo "Written to '${__dir__}/../shared/versions.tf'"

echo "Attempting to install new Terraform version via tfenv"
# tfenv 3.1.0 will support 'tfenv install latest-allowed', but this will have to do unitl then
pushd "${__dir__}/../" >/dev/null || exit
    tfenv install "latest:^${major}.${minor}";
popd >/dev/null|| exit

echo "Setting Terraform version"
pushd "${__dir__}/../../" >/dev/null || exit
    tfenv use "latest:${major}.${minor}"
    tfenv pin
popd >/dev/null || exit

deployments_path=$(readlink -f "${__dir__}/../deployments")
echo "Upgrading Terraform and providers in each deployment"
# while loop recommended by https://www.shellcheck.net/wiki/SC2044
while IFS= read -r -d '' dir
do
    if [ ! -e "${dir}/.terraform.lock.hcl" ]; then
        continue
    fi
    deployment=${dir#"${deployments_path}/"}
    echo "${deployment} ..."
    pushd "${dir}" >/dev/null || exit
        rm ".terraform.lock.hcl"
        terraform init -backend=false -upgrade >/dev/null
    popd >/dev/null || exit
done <   <(find "${deployments_path}" -type d -maxdepth 2 -print0) # (double < required by https://www.shellcheck.net/wiki/SC2044)