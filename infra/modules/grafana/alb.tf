module "certificate" {
  source = "../acm-cert-with-dns-validation"
  providers = {
    aws             = aws
    aws.certificate = aws
  }

  domain_name               = local.host_name
  zone_name                 = var.root_domain
  subject_alternative_names = []
}

resource "aws_security_group" "alb" {
  name        = "${local.name}-alb"
  description = "Allows inbound 443 from trusted networks and outbound to the Grafana container"
  vpc_id      = var.vpc_id

  ingress {
    description = "Port 443 from trusted networks"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  egress {
    description = "Grafana container port within VPC"
    from_port   = local.container_port
    to_port     = local.container_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "aws_lb" "grafana" {
  #checkov:skip=CKV2_AWS_28:Access is limited to trusted networks by the security group and to GitHub team members by Grafana, so a WAF is not considered necessary

  name                       = local.name
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids

  access_logs {
    bucket  = var.alb_access_logs_bucket_name
    prefix  = local.name
    enabled = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_target_group" "grafana" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = local.name
  port        = local.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    path     = "/api/health"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}
