#!/bin/bash

# This script updates the Ruby and Docker Alpine Versions for each app in the
# necessary places to make updating simpler.
#
# Change the NEW_RUBY_VERSION and or the DOCKER_ALPINE_VERSION to the desired
# new version and then run the script. It will create a branch, make the
# necessary updates, commit the changes and push to Github for you to raise a
# PR.

set -e

# Check that Docker is running
if ! docker info > /dev/null 2>&1 ; then
    echo "Docker is not running. Docker is required to find the correct docker
    base image for the new version of Ruby. Start Docker and try again. more
    info here: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Update these values as necessary and then run the script
NEW_RUBY_VERSION="3.2.2"
DOCKER_ALPINE_VERSION="3.18"

# Constants that should not need to be updated
GIT_BRANCH_NAME="bump_ruby_to_${NEW_RUBY_VERSION}"
APPS=(forms-api forms-admin forms-runner forms-product-page forms-e2e-tests)

# Checks out main branch and pulls latests. Then creates a new
# branch for the updates. If the branch already exists it continues
# on and uses it.
setup_git_branch () {
  git checkout main
  git pull
  git branch "$GIT_BRANCH_NAME" || echo "Continuing with existing branch"
  git checkout "$GIT_BRANCH_NAME"
}

# Find the manifest list sha for the version of ruby and alpine
get_new_docker_base_image_sha () {
  docker buildx imagetools inspect ruby:${NEW_RUBY_VERSION}-alpine${DOCKER_ALPINE_VERSION} \
    | grep Digest \
    | cut -d : -f 2-3 \
    | tr -d ' '
}

# Main script begins here
echo "Updating to ${NEW_RUBY_VERSION}"
MANIFEST_LIST_SHA="$(get_new_docker_base_image_sha)"
for app in "${APPS[@]}"; do
  echo -e "\n\n****** BEGINNING UPDATE OF ${app} ********"
  cd "../../${app}"

  setup_git_branch

  echo "Updating .ruby-version file"
  echo "$NEW_RUBY_VERSION" > .ruby-version

  echo "Updating Gemfile"
  sed -i '' 's/^ruby.*$/ruby "'"${NEW_RUBY_VERSION}"'"/' Gemfile

  echo "Running 'bundle install' to update Gemfile.lock"
  bundle install > /dev/null

  echo "Updating version in Dockerfile"
  sed -i '' 's/^FROM ruby:.* AS/FROM ruby:'"${NEW_RUBY_VERSION}"'-alpine'"${DOCKER_ALPINE_VERSION}"'@'"${MANIFEST_LIST_SHA}"' AS/' Dockerfile

  echo "Committing changes"
  git add .ruby-version
  git add Dockerfile
  git add Gemfile
  git add Gemfile.lock
  git commit -S -m "Bump Ruby to ${NEW_RUBY_VERSION}" \
    && git push -u origin "${GIT_BRANCH_NAME}" \
    || echo "There are no commits, perhaps you've already run this script?"
  echo -e "****** FINISHED UPDATING ${app} ********\n\n"
  cd - > /dev/null
done

echo "Now raise a PR for each repo for the branches named ${GIT_BRANCH_NAME}"
