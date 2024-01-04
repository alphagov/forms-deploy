# infra/deployments/account

This Terraform root deployment lays the groundwork in an AWS account, ready for
the subsequent deployment of one of the other deployments in `infra/deployments`.

Example of things configured in this root are:
* Account contact details
* Route53 hosted zones
* IAM roles for humans
* IAM roles for machines

> [!NOTE]
> This code is expected to be run by a human, not a machine.
