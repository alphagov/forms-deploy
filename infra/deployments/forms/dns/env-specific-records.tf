resource "aws_route53_record" "env_specific_record" {
  for_each = { for r in var.additional_dns_records : r.name => r }

  zone_id = var.hosted_zone_id
  name    = each.key != "" ? "${each.key}.${var.root_domain}" : var.root_domain
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
