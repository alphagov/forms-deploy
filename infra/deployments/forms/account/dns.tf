resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "${var.apex_domain}."

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_route53_record" "domain_delegations" {
  for_each = var.dns_delegation_records
  zone_id  = aws_route53_zone.public.id
  name     = each.key
  type     = "NS"
  ttl      = 60
  records  = each.value
}
