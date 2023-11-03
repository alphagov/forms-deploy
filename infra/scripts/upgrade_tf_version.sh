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

if [[ -v TFENV_TERRAFORM_VERSION ]]; then
    cat <<EOF
You have the TFENV_TERRAFORM_VERSION environment variable set. This overrides
the version of Terraform being supplied by tfenv and will cause this script to
fail. You should unset it by running 'unset TFENV_TERRAFORM_VERSION'.
EOF
    exit 1
fi

current_version_constraint=$(jq -r '.terraform.required_version' "${__repo_root__}/infra/shared/versions.tf.json")
echo "Current version constraint: ${current_version_constraint}"

latest_version=$(curl -sL "https://api.github.com/repos/hashicorp/terraform/releases" | jq -rf "${__dir__}/latest-tf-release.jq" | tr -d 'v')
echo "Latest version: ${latest_version}"

major=$(echo "${latest_version}" | cut -d. -f1)
minor=$(echo "${latest_version}" | cut -d. -f2)
new_constraint="~>${major}.${minor}"

echo "Writing new version constraint '${new_constraint}'"
jq --arg constraint "${new_constraint}" '.terraform.required_version = $constraint' "${__repo_root__}/infra/shared/versions.tf.json" > "${__repo_root__}/infra/shared/versions.tf.json.tmp";
rm "${__repo_root__}/infra/shared/versions.tf.json"
mv "${__repo_root__}/infra/shared/versions.tf.json.tmp" "${__repo_root__}/infra/shared/versions.tf.json"
echo "Written to '${__repo_root__}/infra/shared/versions.tf.json'"

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
        # Remove the existing lock file so that we can init
        # without the backend cleanly
        rm -f ".terraform.lock.hcl"

        # Initialize, installing the latest as we go
        terraform init -backend=false -upgrade >/dev/null

        # Add the hashes for each provider and platform to the
        # lock file so that it gets the expected thing everywhere
        terraform providers lock \
          -platform=linux_arm64 \
          -platform=linux_amd64 \
          -platform=darwin_amd64 \
          -platform=windows_amd64 >/dev/null
    popd >/dev/null || exit
done <   <(find "${deployments_path}" -type d -maxdepth 2 -print0) # (double < required by https://www.shellcheck.net/wiki/SC2044)

echo "Setting version constraint in GitHub Actions workflows"
yq -i ".env.TF_VERSION=\"${new_constraint}\"" "${__repo_root__}/.github/workflows/infra-ci.yml"