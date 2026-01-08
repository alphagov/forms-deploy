locals {
  subnets_to_deploy_vpc_endpoints_to = concat(
    [for s in aws_subnet.pipeline_visualiser_subnets : s.id],
  )
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "tools-vpc-endpoints"
  description = "Allow ingress from VPC on port 443"
  vpc_id      = aws_vpc.tools.id

  ingress {
    description = "Port 443 from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tools.cidr_block]
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
  vpc_id              = aws_vpc.tools.id
  service_name        = "com.amazonaws.eu-west-2.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = local.subnets_to_deploy_vpc_endpoints_to

  tags = {
    Name = "tools-ecr-api-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.tools.id
  service_name        = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = local.subnets_to_deploy_vpc_endpoints_to

  tags = {
    Name = "tools-cr-dkr-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.tools.id
  service_name = "com.amazonaws.eu-west-2.s3"
  route_table_ids = concat(
    [aws_route_table.public.id],
    [for rtb in aws_route_table.private : rtb.id],
  )

  tags = {
    Name = "tools-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.tools.id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = local.subnets_to_deploy_vpc_endpoints_to

  tags = {
    Name = "toools-cloudwatch-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.tools.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = local.subnets_to_deploy_vpc_endpoints_to

  tags = {
    Name = "tools-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ses" {
  vpc_id              = aws_vpc.tools.id
  service_name        = "com.amazonaws.eu-west-2.email"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids          = local.subnets_to_deploy_vpc_endpoints_to

  tags = {
    Name = "tools-ses-endpoint"
  }
}
