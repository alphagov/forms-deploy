> [!NOTE]
> This is a private repository due to some concerns raised by GDS IA, see [Assurance Report Use of Github Actions v1.0](https://docs.google.com/document/d/1f-0x5tamO7QjVGivsmFQ5RK9MKM84FRH/).

# forms-deploy
`forms-deploy` composes and deploys the different components of GOV.UK Forms to create a full environment. The major components of the repository are

- [Infrastructure](https://github.com/alphagov/forms-deploy/blob/main/infra/README.md)
- [Local development](https://github.com/alphagov/forms-deploy/blob/main/local/README.md)
- [Supporting scripts](https://github.com/alphagov/forms-deploy/tree/main/support)


## Table of contents

1. [How do I use this repository?](#how-do-i-use-this-repository)
2. [Common tasks](#common-tasks)
3. [Directory of URLs](#directory-of-urls)

## How do I use this repository?

Operations in this repository are largely driven by `make`, and defined in [the `Makefile`](./Makefile).

Using `make` it is possible to deploy any part of the infrastructure to any account. We have designed our Make targets to act like a small CLI tool [^1], and the general structure is

```
make $ACCOUNT $ROOT $ACTION
```

where

* `$ACCOUNT` is the name of the account you have assumed a role in (one of `deploy`, `development`, `staging`, and `production`)
* `$ROOT` is a Terraform root module folder under `infra/deployments`. For example `forms/rds` or `deploy/ecr`. The `account` root is a special case and can be applied as `account`.
* `$ACTION` is the Terraform action you want to take. One of `plan`, `apply,` and `validate`.

> [!TIP]
> Our `make` commands have tab completion! Source the tab completion script for your shell under `support/` (e.g. `support/makefile_completion.bash`) as part of your shell profile.

## Common tasks
#### Updating Terraform 

We have a lot of Terraform code, across a lot of distinct root modules. To keep versioning consistent we have [a shared versions file](infra/shared/versions.tf.json) which is symlinked into each root.

To simplify performing the upgrade, you can run 

```
./infra/scripts/upgrade_tf_version.rb
```

This will find the latest version of Terraform and all of the Terraform providers we use, update the versions file with them, and then update the lock files in each root.

By default the version selected will be the latest full release. If you need to allow the script to pick a pre-release version, use the `--allow-prerelease` flag.

```
./infra/scripts/upgrade_tf_version.rb --allow-prerelease
```

Performing a Terraform upgrade can take a long time, and is prone to failure as a result of network failures. It is useful to perform the upgrade on a fresh checkout of the repository in a temporary directory.

## Directory of URLs

### Admin

- Staging: https://admin.staging.forms.service.gov.uk/
- Production: https://admin.forms.service.gov.uk/

### API

- Staging: https://api.staging.forms.service.gov.uk/
- Production: https://api.forms.service.gov.uk/

### Runner

- Staging: https://submit.staging.forms.service.gov.uk/
- Production: https://submit.forms.service.gov.uk/

### Architecture decision records
https://github.com/alphagov/forms/tree/main/ADR 

[^1]: This should not be confused with `forms-cli` at `support/forms-cli`. `forms-cli` is intended for working with a deployment of GOV.UK Forms, not deploying it.

### Path to production for apps
https://github.com/alphagov/forms-team/wiki/Path-to-production%3a-applications

### Pipeline Visualiser
https://pipelines.tools.forms.service.gov.uk/