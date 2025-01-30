resource "aws_security_group" "review_apps" {
  #checkov:skip=CKV2_AWS_5:The security groups are attached by Terraform in the application repos
  name        = "review-apps"
  description = "Inbound and outbound traffic for instances of review apps running in AWS ECS"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "review_apps_ingress" {
  security_group_id = aws_security_group.review_apps.id

  description = "Allow all TCP traffic within the private subnets"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = module.vpc.private_subnet_cidr_blocks
}

resource "aws_security_group_rule" "review_apps_egress" {
  security_group_id = aws_security_group.review_apps.id

  description = "Allow all TCP traffic within the private subnets"

  type        = "egress"
  protocol    = "tcp"
  from_port   = 0
  to_port     = 65535
  cidr_blocks = module.vpc.private_subnet_cidr_blocks
}
