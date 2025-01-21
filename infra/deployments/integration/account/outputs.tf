output "review_dns_name_servers" {
  description = "The name servers to which control of the review domain should be delegated"
  value       = aws_route53_zone.review.name_servers
}

output "review_dns_zone_id" {
  description = "The id the AWS Route53 Hosted Zone for the review apps environment"
  value       = aws_route53_zone.review.id
}
