# tfvars

This directory contains a set of `.tfvars` files, one for each environment type. They provide the correct parameters for each environment type,
and should be included in Terraform invocations

```
terraform apply /
    -var-file envs/dev.tfvars
```

For the definition of the inputs, see [../inputs.tf](../inputs.tf)