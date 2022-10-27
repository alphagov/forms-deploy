# A demo of running e-2-e tests using ruby and capybara

## Introduction

This is a simple test of using capybara to run e2e tests against the forms service.

There are two tests:
- completing an existing form using the runner 
- logging into the admin

## Getting started
You will need to export the following environment variables for this to able to logging to staging.

You can get the OTP by generating a new code in staging - this might not be very secure though, so ideally use a dedicated account.

```
SIGNON_USERNAME=
SIGNON_PASSWORD=
SIGNON_OTP=
```

Then run the `./run_test.sh` to start a docker container with headless chrome already installed.

## Further work

There is more work to do if we take this route:
- improve tests
- better config via environment
- hook up to github action
- try and make it easier to debug tests, take screenshots etc.
