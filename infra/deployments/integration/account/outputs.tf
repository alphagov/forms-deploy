output "review_dns_name_servers" {
  description = "The name servers to which control of the review domain should be delegated"
  value       = aws_route53_zone.review.name_servers
}
