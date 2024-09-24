output "vpc_id" {
  value = aws_vpc.forms.id
}

output "vpc_cidr_block" {
  value = aws_vpc.forms.cidr_block
}

output "private_subnet_ids" {
  value = {
    "a" = aws_subnet.private_a.id
    "b" = aws_subnet.private_b.id
    "c" = aws_subnet.private_c.id
  }
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
