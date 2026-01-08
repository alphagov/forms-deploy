resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-${var.env_name}"
  description = "Allow ingress from VPC on port 443"
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
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "ecr-api-endpoint-${var.env_name}"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "ecr-dkr-endpoint-${var.env_name}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.forms.id
  service_name = "com.amazonaws.eu-west-2.s3"
  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private_a.id,
    aws_route_table.private_b.id,
    aws_route_table.private_c.id
  ]

  tags = {
    Name = "s3-endpoint-${var.env_name}"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "cloudwatch-endpoint-${var.env_name}"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "ssm-endpoint-${var.env_name}"
  }
}

resource "aws_vpc_endpoint" "ses" {
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.email"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "ses-endpoint-${var.env_name}"
  }
}
