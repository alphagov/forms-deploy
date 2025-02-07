resource "aws_security_group" "traefik" {
  #checkov:skip=CKV2_AWS_5:The security groups are attached in ecs.tf
  name        = "review-traefik"
  description = "Inbound and outbound traffic to Traefik"
  vpc_id      = var.vpc_id

  ingress {
    description = "Permit inbound form the VPC to the container port"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    description = "Permit inbound from the ALB to Traefik healthcheck endpoint"
    from_port   = local.ping_port
    to_port     = local.ping_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    description = "Permit TCP outbound from the container to the VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    description = "Permit outbound from the container to the internet on port 443 (for retrieving Docker containers)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
