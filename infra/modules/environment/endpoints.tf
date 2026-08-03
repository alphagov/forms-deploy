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

resource "aws_vpc_endpoint" "monitoring" {
  # CloudWatch metrics API (GetMetricData/ListMetrics/etc) - needed by
  # Grafana's CloudWatch datasource (infra/modules/tempo/cloudwatch-datasource.tf)
  # for its metrics queries, distinct from the "cloudwatch" endpoint above
  # (that's actually the Logs API).
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.monitoring"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "monitoring-endpoint-${var.env_name}"
  }
}

resource "aws_vpc_endpoint" "oam" {
  # CloudWatch Observability Access Manager - Grafana's CloudWatch
  # datasource calls oam:ListSinks to resolve account context as part of
  # building a Logs Insights query (GET .../resources/accounts), not just
  # as an optional background probe - without this, that call hangs (no
  # internet egress on the tempo/grafana task) and log queries in Explore
  # come back as "no data" rather than a distinct error.
  vpc_id              = aws_vpc.forms.id
  service_name        = "com.amazonaws.eu-west-2.oam"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id,
  ]

  tags = {
    Name = "oam-endpoint-${var.env_name}"
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
