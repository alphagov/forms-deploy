resource "aws_vpc" "tools" {
  #checkov:skip=CKV2_AWS_11:VPC flow logs to be considered https://trello.com/c/1XytsgPE/420-consider-vpc-flow-logs
  #checkov:skip=CKV2_AWS_12

  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tools"
  }
}

resource "aws_default_security_group" "no_access" {
  vpc_id = aws_vpc.tools.id
}
