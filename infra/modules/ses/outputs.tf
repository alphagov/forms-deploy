output "form_submissions_configuration_set_name" {
  description = "The name of the configuration set to use for sending form submissions"
  value       = aws_sesv2_configuration_set.form_submissions.configuration_set_name
}
