output "vpc_id" {
  value = aws_vpc.forms.id
}

output "vpc_cidr_block" {
  value = aws_vpc.forms.cidr_block
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
}

output "cloudfront_arn" {
  value = module.cloudfront[0].cloudfront_arn
}

output "cloudfront_distribution_id" {
  value = module.cloudfront[0].cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  value = module.cloudfront[0].cloudfront_domain_name
}

output "cloudfront_hosted_zone_id" {
  value = module.cloudfront[0].cloudfront_hosted_zone_id
}

output "eventbridge_dead_letter_queue_arn" {
  value = aws_sqs_queue.event_bridge_dlq.arn
}

output "eventbridge_dead_letter_queue_url" {
  value = aws_sqs_queue.event_bridge_dlq.url
}

output "zendesk_alert_us_east_1_topic_arn" {
  value = module.zendesk_alert_us_east_1.topic_arn
}

output "zendesk_alert_eu_west_2_topic_arn" {
  value = module.zendesk_alert_eu_west_2.topic_arn
}

output "pagerduty_eu_west_2_topic_arn" {
  value = module.pagerduty_eu_west_2.topic_arn
}

