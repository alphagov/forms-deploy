module "environment" {
  source             = "../../../modules/environment"
  mutable_image_tags = true # Allow mutable tags in development
  env_name           = "dev"
}

