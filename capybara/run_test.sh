#!/bin/bash

docker run -it --rm --name capybaray -e SIGNON_USERNAME -e SIGNON_PASSWORD -e SIGNON_OTP -v "$PWD":/usr/src/myapp -w /usr/src/myapp $(docker build -q ../.github/workflows/actions/capybara-tests-action/) /bin/bash -c 'bundle && rspec'
