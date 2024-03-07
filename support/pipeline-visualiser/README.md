# Pipeline Visualiser

Pipeline Visualiser provides cross-account visiblity of AWS CodePipeline pipelines, because that's not a feature of the product at the time of writing (March 2024).

## Where can I view it

https://pipelines.tools.forms.service.gov.uk

## How does it work

It assumes each of the roles described in `config.yml`, reads from the CodePipeline API, and then collates and presents that information in the GOV.UK Design System style.

## How can I run it in development?

To be able to run it in development, you must have at least readonly permission in the `deploy` AWS account. 

To run the code successfully, first assume the `readonly` role in the `deploy` account

```
gds aws forms-deploy-readonly --shell
```

Then install the dependencies, and use the Make target `run` to assume the role and begin running the code

```
bundle install
make run
```

This will assume the `deploy-pipeline-visualiser-ecs-task`, which has permission to assume the roles described in `config.yml`.