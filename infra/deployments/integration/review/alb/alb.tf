  ##
# Load balancer
##
resource "aws_lb" "load_balancer" {
  name = "review"

  load_balancer_type         = "application"
  subnets                    = var.subnet_ids
  security_groups            = [aws_security_group.alb.id]
  internal                   = false
  enable_deletion_protection = true
  drop_invalid_header_fields = true

  access_logs {
    bucket  = module.access_logs_bucket.name
    prefix  = "alb"
    enabled = true
  }
}

resource "aws_lb_listener" "tls_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = module.tls_certificate.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service unavailable"
      status_code  = 503
    }
  }
}

