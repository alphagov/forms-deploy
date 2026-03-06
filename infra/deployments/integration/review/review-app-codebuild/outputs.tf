output "project_name" {
  value = aws_codebuild_project.this.name
}

output "project_arn" {
  value = aws_codebuild_project.this.arn
}

output "log_group_arn" {
  value = "${aws_cloudwatch_log_group.codebuild.arn}:*"
}

output "artifacts_path_prefix" {
  value = "${var.artifacts_bucket_name}/${local.project_name}"
}
