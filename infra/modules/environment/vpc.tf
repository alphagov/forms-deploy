resource "aws_vpc" "forms" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "forms-${var.env_name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.forms.id

  tags = {
    Name = "forms-${var.env_name}"
  }
}

resource "aws_security_group" "tls_vpc_only" {
  name        = "tls_within_vpc_${var.env_name}"
  description = "Allows tls within the VPC"
  vpc_id      = aws_vpc.forms.id

  ingress {
    description = "Port 443 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.forms.cidr_block]
  }

  egress {
    description = "Port 443 to VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.forms.cidr_block]
  }
}
