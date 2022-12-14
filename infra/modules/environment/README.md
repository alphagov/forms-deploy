## Overview

This module creates many of the components shared by the GOV.UK Forms applications running on ECS. 


### Network Topology

All infrastructure is deployed into `eu-west-2` (London) and across all three of its Availability Zones (AZ) `eu-west-2a`, `eu-west-2b` and `eu-west-2c`.

The network topology consists of a single public Application Load Balancer (ALB) running within public subnets. The ALB forwards requests to the appropriate ECS service based upon the `host` http header, for example `admin[.dev|.stage].forms.service.gov.uk` is sent to the `forms-admin` ECS service. The ECS services run in private subnets with public internet egress provided via a NAT gateway where the ECS service's security group permits. Each private subnet has a NAT gateway to provide full AZ isolation. Access from the VPC to AWS services is provided via VPC Endpoints.


### TLS Certificate

A certificate is created via Amazon Certificate Manager (ACM) and attached to the ALB listener for the domain with alternate names to cover each of the sub-domains used by each of the three GOV.UK Forms applications and the product pages:
- `[dev.|stage.]forms.service.gov.uk` -> domain
- `admin[.dev|.stage].forms.service.gov.uk` -> forms-admin
- `api[.dev|.stage].forms.service.gov.uk` -> forms-api
- `submit[.dev|.stage].forms.service.gov.uk` -> forms-runner
- `www[.dev|.stage].forms.service.gov.uk` -> product pages