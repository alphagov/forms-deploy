module "environment" {
  source             = "../../../modules/environment"
  mutable_image_tags = true # Allow mutable tags whilst building envs
  env_name           = "staging"
}

