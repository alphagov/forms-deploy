module "waf_protection" {
  source = "../../../../modules/alb_waf_protection"

  alb_arn          = aws_lb.load_balancer.arn
  environment_name = "review"
}
