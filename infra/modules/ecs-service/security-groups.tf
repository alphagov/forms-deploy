data "aws_vpc" "forms" {
  filter {
    name   = "tag:Name"
    values = ["forms-${var.env_name}"]
  }
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_vpc.forms.id
  service_name = "com.amazonaws.eu-west-2.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = data.aws_vpc_endpoint.s3.prefix_list_id
}

resource "aws_security_group" "baseline" {
  name        = "forms-baseline-${var.env_name}"
  description = "Ingress from VPC, egress to VPC and S3"
  vpc_id      = data.aws_vpc.forms.id

  ingress {
    description = "Container port from VPC"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.forms.cidr_block]
  }

  egress {
    description = "Port 443 to VPC and S3"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = flatten([
      data.aws_vpc.forms.cidr_block,
      data.aws_prefix_list.private_s3.cidr_blocks
    ])
  }
}
