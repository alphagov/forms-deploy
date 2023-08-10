terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # aws.certificate is used when creating the certificate.
      # CloudFront requires the certificate in us-east-1 whilst
      # the ALB certificate is created in eu-west-2.
      configuration_aliases = [aws.certificate]
    }
  }
}
