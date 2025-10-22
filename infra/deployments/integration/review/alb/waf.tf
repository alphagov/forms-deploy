module "waf_protection" {
  source = "../../../../modules/alb_waf_protection"

  alb_arn                = aws_lb.load_balancer.arn
  environment_name       = "review"
  send_logs_to_cyber     = var.send_logs_to_cyber
  log_to_splunk_settings = var.log_to_splunk_settings

}
