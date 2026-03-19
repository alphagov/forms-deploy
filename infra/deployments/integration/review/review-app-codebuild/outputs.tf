output "project_name" {
  value = aws_codebuild_project.this.name
}

output "project_arn" {
  value = aws_codebuild_project.this.arn
}

output "log_group_arn" {
  value = "${aws_cloudwatch_log_group.codebuild.arn}:*"
}
