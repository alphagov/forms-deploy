#!/bin/bash

docker run -it --rm --name capybarat -e SIGNON_USERNAME -e SIGNON_PASSWORD -e SIGNON_OTP -v "$PWD":/usr/src/myapp -w /usr/src/myapp $(docker build -q ../.github/actions/capybara-tests-action/) 'bundle install && bundle exec rspec spec/features/runner_spec.rb'
