output "route53_hosted_zone_id" {
  value = aws_route53_zone.public.id
}

output "private_internal_zone_id" {
  value = aws_route53_zone.private_internal.id
}