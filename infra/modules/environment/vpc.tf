
resource "aws_vpc" "forms" {
  #checkov:skip=CKV2_AWS_11:VPC flow logs to be considered https://trello.com/c/1XytsgPE/420-consider-vpc-flow-logs
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "forms-${var.env_name}"
  }
}

// This ensures the default security group provides no ingress or egress
resource "aws_default_security_group" "no_access" {
  vpc_id = aws_vpc.forms.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.forms.id

  tags = {
    Name = "forms-${var.env_name}"
  }
}
