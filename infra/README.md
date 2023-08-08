## GOV.UK Forms Infrastructure

### Introduction

All infrastructure for GOV.UK Forms is managed within this directory using Terraform. The `infra/deployments` directory contains all of the Terraform deployments from which the `terraform` commands should be run. The structure of the `deployments` directory is:

`deployments/<environment>/<deployment>`

The `modules` directory contains reusable Terraform modules which are referenced by the various deployments.

### How to manage the deployments

Most of the deployments need to be applied by an engineer from their machine; this will likely change in future as our deployment pipelines are extended to manage all deployments.

The following deployments manage the three GOV.UK Forms applications and are automatically applied by CodePipeline when the application code is updated in Github. These should only be run by an engineer from their machine in exceptional circumstances (see deployment pipelines section below).
- `deployments/*/forms-admin`
- `deployments/*/forms-api`
- `deployments/*/forms-runner`

The remaining deployments should be applied by running the `terraform` command from the necessary deployment directory. When running the `terraform` commands the shell must be authenticated with a role that has the necessary AWS permissions to manage the resources being modified. The simplest way is to use `aws-vault` or `gds-cli`.

For example to apply the `redis` deployment to the `development` environment:
- `cd` into `infra/deployments/development/redis`
- Run `aws-vault exec dev-admin -- terraform init`
- Run `aws-vault exec dev-admin -- terraform apply`


### Deployment order and dependencies

The following provides a high-level overview of the deployments and in which order they should be applied if starting from scratch. Some modules contain a `README.md` which should be referenced for more specific instructions.

#### Development, Staging or Production Environment
In the unlikely event of needing to recreate an entire GOV.UK Forms environment the following order should be followed.
- `engineer-access` to grant access to engineers to perform the following. If necessary ask an AWS admin to create a bootstrap role to provide authorization to apply the `engineer-access` deployment.
- `dns` to create a Route53 hosted zone and records which resolve the environment's domain to the Application Load Balancer created by the `environment` deployment. If this is not production environment then copy the name server addresses from the output and update the `deployments/production/dns/main.ts` file to use the new name server addresses.
- `environment` to create the networking and common components for each GOV.UK Forms application.
- `rds` to create the Postgres database cluster used by `forms-admin` and `forms-api`.
- `redis` to create the Redis cluster used by `forms-runner`.
- `deployer-access` to create a role that can be used by the deployment pipelines in the `deploy` environment to deploy the GOV.UK Forms applications.

At this point the pipelines in `deploy` environment can be triggered which will deploy `forms-admin`, `forms-api` and `forms-runner` deployments into the environment.

#### Deploy Environment
To recreate the `deploy` environment.
- `engineer-access` to grant access to engineers to perform the following. If necessary ask an AWS admin to create a bootstrap role to provide authorization to apply the `engineer-access` deployment.
- `ecr` to create the ECR repositories that store the Docker images used by the ECS services in each environment.
- `forms-admin-pipeline`, `forms-api-pipeline` and `forms-runner-pipeline` to create the CodePipeline pipelines and CodeBuild projects.
- `deployments/*/deployer-access` may need applying to ensure the trust policy for the deployer role in each environment includes the newly created IAM roles used by CodeBuild projects.


### DNS For GOV.UK Forms

The `forms.service.gov.uk` domain is delegated to a Route53 Hosted Zone in our production environment. The `deployments/production/dns` deployment manages records to delegate the `dev.` and `staging.` subdomains to Route53 Hosted Zones in the development and staging environments respectively. This is achieved by creating `NS` records within the production Hosted Zone which point to the name server addresses output by the `deployments/development/dns` and `deployments/staging/dns` deployments.


### Linting and Static Analysis

[pre-commit](https://pre-commit.com/) runs checks on the Terraform code each time a developer runs `git commit`. The checks are defined within `forms-deploy/pre-commit-config.yaml` and include the following:
- [Terraform format](https://developer.hashicorp.com/terraform/cli/commands/fmt)
- [Checkov static analysis](https://www.checkov.io/)

Each developer working on the Terraform must install pre-commit and initialize it for this repo along with installing the necessary binaries to run the checks, for example `checkov`. Follow the instructions at the links above for guidance.

A Github Action Workflow runs `checkov` on the Terraform files within this repo on each PR. It is defined within `forms-deploy/.github/workflows/infra-ci.yml`.
