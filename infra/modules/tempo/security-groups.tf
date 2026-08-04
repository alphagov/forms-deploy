data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = data.aws_vpc_endpoint.s3.prefix_list_id
}

resource "aws_security_group" "tempo" {
  #checkov:skip=CKV2_AWS_5:The security group is attached in ecs.tf
  name        = "tempo-${var.env_name}"
  description = "Ingress from VPC to Grafana/Tempo, egress to VPC and S3"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress_grafana" {
  description       = "permit inbound from the VPC to the Grafana UI port"
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.tempo.id
}

resource "aws_security_group_rule" "ingress_otlp_http" {
  description       = "permit inbound from the VPC to the Tempo OTLP/HTTP receiver port"
  type              = "ingress"
  from_port         = 4318
  to_port           = 4318
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.tempo.id
}

resource "aws_security_group_rule" "ingress_tempo_server" {
  description       = "permit inbound from the VPC to Tempo main server port, used for the internal ALB health check"
  type              = "ingress"
  from_port         = 3200
  to_port           = 3200
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.tempo.id
}

resource "aws_security_group_rule" "egress_to_s3_endpoint" {
  description       = "permit outbound to the AWS S3 ip addresses"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = flatten(data.aws_prefix_list.private_s3.cidr_blocks)
  security_group_id = aws_security_group.tempo.id
}

resource "aws_security_group_rule" "egress_to_vpc_https" {
  description       = "permit outbound to the VPC CIDR on 443 (ECR, CloudWatch logs and SSM interface endpoints)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.tempo.id
}

resource "aws_security_group_rule" "egress_to_mimir_alb" {
  description       = "permit outbound to the VPC CIDR on 80 (grafana querying + tempo remote-writing to mimir via the internal ALB)"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.tempo.id
}

data "github_ip_ranges" "current" {}

resource "aws_security_group_rule" "egress_to_github_api" {
  description       = "permit outbound to GitHub published API IP ranges (grafana-github-datasource)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = data.github_ip_ranges.current.api_ipv4
  security_group_id = aws_security_group.tempo.id
}

resource "aws_security_group" "mimir" {
  #checkov:skip=CKV2_AWS_5:The security group is attached in mimir.tf
  name        = "tempo-${var.env_name}-mimir"
  description = "Ingress from VPC to Mimir, egress to S3 and VPC"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "mimir_ingress" {
  description       = "permit inbound from the VPC to the Mimir port, used by the internal ALB (routing + health check) and tempo remote-write"
  type              = "ingress"
  from_port         = 9009
  to_port           = 9009
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.mimir.id
}

resource "aws_security_group_rule" "mimir_egress_to_s3_endpoint" {
  description       = "permit outbound to the AWS S3 ip addresses (ECR image layers and mimir own object storage)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = flatten(data.aws_prefix_list.private_s3.cidr_blocks)
  security_group_id = aws_security_group.mimir.id
}

resource "aws_security_group_rule" "mimir_egress_to_vpc_https" {
  description       = "permit outbound to the VPC CIDR on 443 (ECR, CloudWatch logs and SSM interface endpoints)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.mimir.id
}

resource "aws_security_group" "alloy" {
  #checkov:skip=CKV2_AWS_5:The security group is attached in alloy.tf
  name        = "tempo-${var.env_name}-alloy"
  description = "Ingress from VPC to Alloy, egress to Tempo/Mimir and VPC"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "alloy_ingress_otlp" {
  description       = "permit inbound from the VPC to the Alloy OTLP receiver port"
  type              = "ingress"
  from_port         = 4318
  to_port           = 4318
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.alloy.id
}

resource "aws_security_group_rule" "alloy_ingress_ui" {
  description       = "permit inbound from the VPC to Alloy own UI/API port, used for the internal ALB health check"
  type              = "ingress"
  from_port         = 12345
  to_port           = 12345
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.alloy.id
}

resource "aws_security_group_rule" "alloy_egress_to_s3_endpoint" {
  description       = "permit outbound to the AWS S3 ip addresses (ECR image layers)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = flatten(data.aws_prefix_list.private_s3.cidr_blocks)
  security_group_id = aws_security_group.alloy.id
}

resource "aws_security_group_rule" "alloy_egress_to_vpc_https" {
  description       = "permit outbound to the VPC CIDR on 443 (ECR, CloudWatch logs and SSM interface endpoints)"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.alloy.id
}

resource "aws_security_group_rule" "alloy_egress_to_internal_alb" {
  description       = "permit outbound to the VPC CIDR on 80 (forwarding traces to tempo and remote-writing/scraping metrics via mimir, both over the internal ALB)"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.alloy.id
}
