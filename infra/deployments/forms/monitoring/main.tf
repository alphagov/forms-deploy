resource "aws_cloudwatch_dashboard" "overview" {
  dashboard_name = "Overview"
  dashboard_body = file("dashboard_body.json")
}
