# Public: Grafana UI, reached via CloudFront -> public ALB -> this target group.
resource "aws_lb_target_group" "grafana" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "tempo-grafana-${var.env_name}"
  port        = 3000
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

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = var.alb_listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = ["tempo.${var.root_domain}"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-CloudFront-Secret"
      values           = [var.cloudfront_secret]
    }
  }
}

# Internal: OTLP/HTTP trace ingestion from other ECS services, reached via the
# internal ALB only - this never needs to be public. OTLP/HTTP (not gRPC) is
# used deliberately so this can use the existing plain-HTTP internal listener,
# the same as every other internal app-to-app route in this repo; a gRPC
# target group would require the internal HTTPS listener plus SNI cert
# coverage, which isn't worth the complexity for a POC.
resource "aws_lb_target_group" "tempo_otlp" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "tempo-otlp-${var.env_name}"
  port        = 4318
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    # The OTLP/HTTP receiver on 4318 only serves trace ingestion, not a
    # health endpoint, so health-check Tempo's main server port instead
    # while still routing real traffic to the OTLP port above.
    port     = "3200"
    path     = "/ready"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener_rule" "tempo_otlp" {
  listener_arn = var.internal_alb_listener_arn
  priority     = var.internal_listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo_otlp.arn
  }

  condition {
    host_header {
      values = ["tempo-otlp.internal.${var.root_domain}"]
    }
  }
}

# Internal: mimir is reached over the internal ALB only, by tempo's
# metrics_generator (remote_write) and grafana's datasource (query) - see
# mimir.tf for why mimir is its own S3-backed ECS service.
resource "aws_lb_target_group" "mimir" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "tempo-mimir-${var.env_name}"
  port        = 9009
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    path     = "/ready"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener_rule" "mimir" {
  listener_arn = var.internal_alb_listener_arn
  # +1 offset from var.internal_listener_priority: this rule shares the same
  # internal listener as tempo_otlp above, which already uses
  # var.internal_listener_priority directly - priorities must be unique per
  # listener. Mirrors the same pattern used by
  # infra/modules/ecs-service/alb.tf's apex_rule.
  priority = var.internal_listener_priority + 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mimir.arn
  }

  condition {
    host_header {
      values = ["mimir.internal.${var.root_domain}"]
    }
  }
}

# Internal: alloy is the OTLP entry point for all three apps (forms-admin,
# forms-runner and its queue worker), forwarding on to tempo after dropping
# SolidQueue polling noise - see alloy.tf/docker/alloy/config.alloy.
resource "aws_lb_target_group" "alloy" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "tempo-alloy-${var.env_name}"
  port        = 4318
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    # The OTLP/HTTP receiver on 4318 only serves trace ingestion, not a
    # health endpoint, so health-check alloy's own UI/API server instead
    # while still routing real traffic to the OTLP port above.
    port     = "12345"
    path     = "/-/ready"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener_rule" "alloy" {
  listener_arn = var.internal_alb_listener_arn
  # +2 offset from var.internal_listener_priority, continuing the same
  # sequence as tempo_otlp (base) and mimir (+1) above.
  priority = var.internal_listener_priority + 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alloy.arn
  }

  condition {
    host_header {
      values = ["alloy-otlp.internal.${var.root_domain}"]
    }
  }
}
