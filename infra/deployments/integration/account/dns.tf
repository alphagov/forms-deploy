# The "review." Route53 zone exists in the account root
# so that the zone is created before integration/review is
# run, and we've had opportunity to delegate the DNS from
# the production account.
resource "aws_route53_zone" "review" {
  #checkov:skip=CKV2_AWS_38:DNSSEC is not currently necessary
  #checkov:skip=CKV2_AWS_39:DNS query logging not necessary
  name = "review.forms.service.gov.uk"
}
