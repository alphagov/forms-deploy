resource "aws_cloudwatch_log_group" "log" {
  name = "${var.application}-${var.env_name}"
}

