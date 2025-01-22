resource "aws_security_group" "alb" {
  name        = "review-ingress-and-egress"
  description = "Allows public inbound on 443 and outbound to VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Port 443 from public"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Any port within VPC using TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}
