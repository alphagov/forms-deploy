#!/usr/bin/env bash

__dir__=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
__repo_root__=$(readlink -f "${__dir__}/../../")

if ! command -v tfenv >/dev/null; then
    echo "You must have tfenv installed"
    exit 1
fi

if ! command -v jq >/dev/null; then
    echo "You must have jq installed"
    exit 1
fi

current_version_constraint=$(sed -nr 's#.*required_version = "(.*)"#\1#p' "${__repo_root__}/infra/shared/versions.tf")
echo "Current version constraint: ${current_version_constraint}"

latest_version=$(curl -sL "https://api.github.com/repos/hashicorp/terraform/releases" | jq -rf "${__dir__}/latest-tf-release.jq" | tr -d 'v')
echo "Latest version: ${latest_version}"

major=$(echo "${latest_version}" | cut -d. -f1)
minor=$(echo "${latest_version}" | cut -d. -f2)
new_constraint="~>${major}.${minor}"

echo "Writing new version constraint '${new_constraint}'"
sed -r -i.bak "s%(.*)required_version = \"(.*)\"%\1required_version = \"${new_constraint}\"%g" "${__repo_root__}/infra/shared/versions.tf"
rm "${__repo_root__}/infra/shared/versions.tf.bak"

echo "Written to '${__repo_root__}/infra/shared/versions.tf'"

echo "Attempting to install new Terraform version via tfenv"
# tfenv 3.1.0 will support 'tfenv install latest-allowed', but this will have to do unitl then
pushd "${__repo_root__}/infra" >/dev/null || exit
    tfenv install "latest:^${major}.${minor}";
popd >/dev/null|| exit

echo "Setting Terraform version"
pushd "${__repo_root__}/infra" >/dev/null || exit
    tfenv use "latest:${major}.${minor}"

    # 'tfenv pin' gets confused by the presence of the `.terraform-version` file
    # and pins the version it sees in there. To work around that, we override the
    # file using the environment variable
    TFENV_TERRAFORM_VERSION="latest:${major}.${minor}" tfenv pin
popd >/dev/null || exit

deployments_path=$(readlink -f "${__repo_root__}/infra/deployments")
echo "Upgrading Terraform and providers in each deployment"
# while loop recommended by https://www.shellcheck.net/wiki/SC2044
while IFS= read -r -d '' dir
do
    # If there's no `main.tf` it's probably not a Terraform deployment
    if [ ! -e "${dir}/main.tf" ]; then
        continue
    fi
    deployment=${dir#"${deployments_path}/"}
    echo "${deployment} ..."
    pushd "${dir}" >/dev/null || exit
        rm ".terraform.lock.hcl"
        terraform init -backend=false -upgrade >/dev/null
    popd >/dev/null || exit
done <   <(find "${deployments_path}" -type d -maxdepth 2 -print0) # (double < required by https://www.shellcheck.net/wiki/SC2044)

echo "Setting version constraint in GitHub Actions workflows"
yq -i ".env.TF_VERSION=\"${new_constraint}\"" "${__repo_root__}/.github/workflows/infra-ci.yml"