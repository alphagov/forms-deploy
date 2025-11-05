output "route53_hosted_zone_id" {
  value = aws_route53_zone.public.id
}

output "private_internal_zone_id" {
  value = aws_route53_zone.private_internal.id
}

output "kinesis_destination_arn" {
  value = var.kinesis_destination_arn
}

output "kinesis_destination_arn_us_east_1" {
  value = var.kinesis_destination_arn_us_east_1
}

output "kinesis_subscription_role_arn" {
  value = aws_iam_role.kinesis_subscription_role[0].arn
}
