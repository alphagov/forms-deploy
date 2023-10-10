## Overview

This module configures Auth0 tenants for authenticating users of the GOV.UK Forms admin app.

### Secrets

To be able to use this module, you will need the client ID and client secret of the machine to machine application in the GOV.UK Forms tenant for the environment you are terraforming. Store these secrets in the AWS SSM Parameter Store for the related AWS account. The deployment module should then configure the provider with these values (see [/infra/deployments/development/auth0/main.tf]() for an example).

Note that when bootstrapping you will need to create a tenant and machine to machine application following the steps in the Auth0 provider documentation [[1]]. You will also want to delete the default authentication methods, (password database and Google OAuth2) as we don't need them and by default new clients created by terraform will use them if they are present. And you will need to make sure SES has been deployed.

[1]: https://registry.terraform.io/providers/auth0/auth0/1.0.0-beta.2/docs/guides/quickstart
