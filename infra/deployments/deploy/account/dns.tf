resource "aws_route53_zone" "tools_zone" {
  #checkov:skip=CKV2_AWS_39:No desire for DNS query logging
  #checkov:skip=CKV2_AWS_38:No need for DNSSEC
  name = "tools.forms.service.gov.uk."
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_zone" "status_zone" {
  #checkov:skip=CKV2_AWS_39:No desire for DNS query logging
  #checkov:skip=CKV2_AWS_38:No need for DNSSEC
  name = "status.forms.service.gov.uk."
  lifecycle {
    prevent_destroy = true
  }
}
