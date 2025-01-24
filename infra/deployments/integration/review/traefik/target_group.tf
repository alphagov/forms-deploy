resource "aws_lb_target_group" "tg" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our VPC and we do not want the complexity cost of setting up TLS between the load balancer and Traefik
  name        = "review-traefik"
  port        = local.http_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    path     = "/ping"
    port     = local.api_port
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener_rule" "to_traefik" {
  listener_arn = var.alb_tls_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["*.review.forms.service.gov.uk"]
    }
  }
}