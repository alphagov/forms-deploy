locals {
  # The ordering here is arbitary so long as they don't clash.
  listner_priority = {
    forms-runner : 100
    forms-api : 200
    forms-admin : 300
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "forms-${var.application}-${var.env_name}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.forms.id
  target_type = "ip"

  health_check {
    path     = "/ping"
    matcher  = "200"
    protocol = "HTTP"
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
  priority     = lookup(local.listner_priority, var.application)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${var.sub_domain}.*"]
    }
  }
}

