module "tls_certificate" {
  source = "../../../../modules/acm-cert-with-dns-validation"
  providers = {
    aws             = aws
    aws.certificate = aws # Create the certificate in the default eu-west-2
  }

  domain_name               = "review.forms.service.gov.uk"
  subject_alternative_names = ["*.review.forms.service.gov.uk"]
}
