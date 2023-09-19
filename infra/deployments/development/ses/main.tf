module "ses" {
  source = "../../../modules/ses"
}

output "smtp_username" {
  value     = module.ses
  sensitive = true
}
