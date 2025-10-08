# The module will need to be given a different provider
# to use so it can create things in different regions.
#
# To do that, we have to declare what providers we needed
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
