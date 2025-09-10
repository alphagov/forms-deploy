locals {
  # The ordering here is arbitrary so long as they don't clash.
  listener_priority = {
    forms-runner : 100
    forms-api : 200
    forms-admin : 300
    forms-product-page : 400
  }
}

resource "aws_lb_target_group" "tg" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "${var.application}-${var.env_name}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    path     = "/up"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

module "environment_names" {
  source = "../environment-names"
}

resource "aws_lb_target_group" "internal_tg" {
  count = var.internal_sub_domain != null ? 1 : 0
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "${var.application}-${module.environment_names.environment_short_names[var.env_name]}-internal"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    path     = "/up"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "to_app" {
  listener_arn = var.alb_listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = [var.sub_domain]
    }
  }

  condition {
    http_header {
      http_header_name = "X-CloudFront-Secret"
      values           = [var.cloudfront_secret]
    }
  }
}

resource "aws_lb_listener_rule" "internal_alb_to_app" {
  count        = var.internal_sub_domain != null ? 1 : 0
  listener_arn = var.internal_alb_listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_tg[0].arn
  }

  condition {
    host_header {
      values = [var.internal_sub_domain]
    }
  }
}

resource "aws_lb_listener_rule" "apex_rule" {
  count = var.include_domain_root_listener ? 1 : 0

  listener_arn = var.alb_listener_arn
  priority     = var.listener_priority + 1

  action {
    type = "redirect"
    redirect {
      host        = var.sub_domain
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [var.root_domain]
    }
  }

  condition {
    http_header {
      http_header_name = "X-CloudFront-Secret"
      values           = [var.cloudfront_secret]
    }
  }
}
