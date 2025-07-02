output "route53_hosted_zone_id" {
  value = aws_route53_zone.public.id
}

output "internal_kms_key_id" {
  value = aws_kms_key.internal.id
}