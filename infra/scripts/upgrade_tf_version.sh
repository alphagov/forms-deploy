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

function update_versions_tf {
    jq_path="$1"
    new_value="$2"

    jq -r --arg value "${new_value}" "${jq_path} = \$value" "${__repo_root__}/infra/shared/versions.tf.json" > "${__repo_root__}/infra/shared/versions.tf.json.tmp"
    rm "${__repo_root__}/infra/shared/versions.tf.json"
    mv "${__repo_root__}/infra/shared/versions.tf.json.tmp" "${__repo_root__}/infra/shared/versions.tf.json"
    echo "Written to '${__repo_root__}/infra/shared/versions.tf.json'"
}

current_tf_version_constraint=$(jq -r '.terraform.required_version' "${__repo_root__}/infra/shared/versions.tf.json")
echo "Current Terraform version constraint: ${current_tf_version_constraint}"

current_aws_version_constraint=$(jq -r '.terraform.required_providers.aws' "${__repo_root__}/infra/shared/versions.tf.json")
echo "Current AWS provider version constraint: ${current_aws_version_constraint}"

latest_tf_version=$(curl -sL "https://api.github.com/repos/hashicorp/terraform/releases" | jq -rf "${__dir__}/latest-release.jq" | tr -d 'v')
echo "Latest Terraform version: ${latest_tf_version}"

tf_major=$(echo "${latest_tf_version}" | cut -d. -f1)
tf_minor=$(echo "${latest_tf_version}" | cut -d. -f2)
tf_patch=$(echo "${latest_tf_version}" | cut -d. -f3)
new_tf_constraint="~>${tf_major}.${tf_minor}.${tf_patch}"

latest_aws_version=$(curl -sL "https://api.github.com/repos/hashicorp/terraform-provider-aws/releases" | jq -rf "${__dir__}/latest-release.jq" | tr -d 'v')
echo "Latest AWS provider version: ${latest_aws_version}"

aws_major=$(echo "${latest_aws_version}" | cut -d. -f1)
aws_minor=$(echo "${latest_aws_version}" | cut -d. -f2)
aws_patch=$(echo "${latest_aws_version}" | cut -d. -f3)
new_aws_constraint="~>${aws_major}.${aws_minor}.${aws_patch}"

if [[ "${current_tf_version_constraint}" == "${new_tf_constraint}" ]] && [[ "${current_aws_version_constraint}" == "${new_aws_constraint}" ]]; then
    echo "There are no new versions. Not doing anything."
    exit 0
fi

current_aws_major_version=$(echo "${current_aws_version_constraint}" | tr -d '~>' | cut -d '.' -f1)
if [ "${aws_major}" -gt "${current_aws_major_version}" ]; then
    echo "WARNING! AWS provider major version is increasing. There may be breaking changes."
fi

echo "Writing new Terraform version constraint '${new_tf_constraint}'"
update_versions_tf '.terraform.required_version' "${new_tf_constraint}"

echo "Writing new AWS provider version constraint '${new_aws_constraint}'"
update_versions_tf '.terraform.required_providers.aws' "${new_aws_constraint}"

echo "Attempting to install new Terraform version via tfenv"
# tfenv 3.1.0 will support 'tfenv install latest-allowed', but this will have to do unitl then
pushd "${__repo_root__}/infra" >/dev/null || exit
    tfenv install "latest:^${tf_major}.${tf_minor}";
popd >/dev/null|| exit

echo "Setting Terraform version"
pushd "${__repo_root__}/infra" >/dev/null || exit
    tfenv use "latest:${tf_major}.${tf_minor}"

    # 'tfenv pin' gets confused by the presence of the `.terraform-version` file
    # and pins the version it sees in there. To work around that, we override the
    # file using the environment variable
    TFENV_TERRAFORM_VERSION="latest:${tf_major}.${tf_minor}" tfenv pin
popd >/dev/null || exit


echo "Setting default Terraform version in CodePipeline configuration to '${latest_tf_version}'"
jq -r --arg version "${latest_tf_version}" \
    '.variable.terraform_version.default = $version' \
    "${__repo_root__}/infra/modules/code-build-deploy-ecs/terraform_version.tf.json" \
> "${__repo_root__}/infra/modules/code-build-deploy-ecs/terraform_version.tf.json.tmp"
rm "${__repo_root__}/infra/modules/code-build-deploy-ecs/terraform_version.tf.json"
mv "${__repo_root__}/infra/modules/code-build-deploy-ecs/terraform_version.tf.json.tmp" "${__repo_root__}/infra/modules/code-build-deploy-ecs/terraform_version.tf.json"
echo "Written to '${__repo_root__}/infra/modules/code-build-deploy-ecs/terraform_version.tf.json.tmp'"

deployments_path=$(readlink -f "${__repo_root__}/infra/deployments")
echo "Upgrading Terraform and providers in each deployment"
# while loop recommended by https://www.shellcheck.net/wiki/SC2044
while IFS= read -r -d '' dir
do
    deployment=${dir#"${deployments_path}/"}
    echo "${deployment} ..."
    pushd "${dir}" >/dev/null || exit
        # Remove the existing lock file so that we can init
        # without the backend cleanly
        rm -f ".terraform.lock.hcl"
        rm -rf ".terraform/"

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
done <   <(find "${deployments_path}" -type d -depth 2 -print0) # (double < required by https://www.shellcheck.net/wiki/SC2044)

echo "Setting version constraint in GitHub Actions workflows"
yq -i ".env.TF_VERSION=\"${new_tf_constraint}\"" "${__repo_root__}/.github/workflows/infra-ci.yml"