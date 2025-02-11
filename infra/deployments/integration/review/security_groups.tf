resource "aws_security_group" "review_apps" {
  #checkov:skip=CKV2_AWS_5:The security groups are attached by Terraform in the application repos
  #checkov:skip=CKV_AWS_23:Rules are self explanatory
  name        = "review-apps"
  description = "Inbound and outbound traffic for instances of review apps running in AWS ECS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnet_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnet_cidr_blocks
  }

  egress {
    description = "TLS egress to the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
