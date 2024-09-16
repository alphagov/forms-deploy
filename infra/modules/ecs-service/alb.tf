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

data "aws_lb" "alb" {
  name = "forms-${var.env_name}"
}

data "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 443
}

resource "aws_lb_listener_rule" "to_app" {
  listener_arn = data.aws_lb_listener.main.arn
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
}

resource "aws_lb_listener_rule" "apex_rule" {
  count = var.application == "forms-product-page" ? 1 : 0

  listener_arn = data.aws_lb_listener.main.arn
  priority     = var.listener_priority + 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = [var.root_domain]
    }
  }
}
