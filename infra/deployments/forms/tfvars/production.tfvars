allowed_account_ids = ["443944947292"]
deploy_account_id   = "711966560482"
account_name        = "production"
default_tags = {
  Environment = "production"
}
environment_name = "production"
environment_type = "production"
environmental_settings = {
  auth0_domain                             = "govuk-forms.uk.auth0.com"
  disable_auth0                            = false
  enable_auth0_splunk_log_stream           = true
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 60 * 60 * 24
  # Set to 24 hours for inactivity just in case the pause_database_on_inactivity flag is inverted or ignored
  database_backup_retention_period_days = 30
  enable_alert_actions                  = true
  allow_authentication_from_email_domains = [
    ".gov.uk",
    ".mod.uk",
    "@cefas.co.uk",
    "@certoffice.org",
    "@ddc-mod.org",
    "@hs2.org.uk",
    "@innovateuk.ukri.org",
    "@mod.uk",
    "@nationalhighways.co.uk",
    "@naturalengland.org.uk",
    "@slc.co.uk",
    "@ukces.org.uk",
    "@ukri.org",
    "@dounreay.com",
    "@marinemanagement.org.uk",
    "@gov.scot",
    "@dhsc.egresscloud.com"
  ]
  forms_product_page_support_url      = "https://www.forms.service.gov.uk/support"
  rds_maintenance_window              = "wed:04:00-wed:04:30"
  ips_to_block                        = []
  enable_shield_advanced_healthchecks = true
}
root_domain = "forms.service.gov.uk"
additional_dns_records = [
  # Records in support of MyNCSC Web Check
  {
    # Validation record for apex domain
    name    = "_asvdns-3135bcc2-f3a6-4575-99e3-107b802607ab"
    type    = "TXT"
    ttl     = 86400
    records = ["asvdns_ba7549ac-6142-4838-a85d-aad0cd4e3238"]
  },
  {
    # Validation record for submit.
    name    = "_asvdns-677c95c4-4883-49c1-aaaf-d5d357de6214.submit"
    type    = "TXT"
    ttl     = 86400
    records = ["asvdns_1562e193-1dda-4dff-b80f-30a51d40f9fa"]
  },
  {
    # Validation record for admin.
    name    = "_asvdns-7ccd9131-fdea-4bcf-9ee3-980f751ccff6.admin"
    type    = "TXT"
    ttl     = 86400
    records = ["asvdns_c563af35-dcf1-40c6-b2c0-bc2719a2c2fc"]
  },
  {
    # Validation record for www.
    name    = "_asvdns-b4f022ae-7033-40d5-bd61-1465c9ea5a30.www"
    type    = "TXT"
    ttl     = 86400
    records = ["asvdns_61809fb0-4bf0-4e8e-82e2-e6febfba9faa"]
  },
  {
    # Validation record for api.
    name    = "_asvdns-453532a6-2653-4d64-a5b2-8bd02812ccea.api"
    type    = "TXT"
    ttl     = 86400
    records = ["asvdns_1d96d003-5726-4840-b265-4b5f6e08094a"]
  },


  # Records in support of MyNCSC MailCheck
  {
    # DMARC reporting record for apex domain
    name    = "_dmarc"
    type    = "TXT"
    ttl     = 86400
    records = ["v=DMARC1; p=none; rua=mailto:dmarc-rua@dmarc.service.gov.uk;"]
  },
  {
    # DMARC reporting record for submit.
    name    = "_dmarc.submit"
    type    = "TXT"
    ttl     = 86400
    records = ["v=DMARC1; p=none; rua=mailto:dmarc-rua@dmarc.service.gov.uk;"]
  }
]
codestar_connection_arn = "arn:aws:codestar-connections:eu-west-2:443944947292:connection/c253c931-651d-4d48-950a-c1ac2dfd7ca8"
container_registry      = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 6
  max_capacity               = 12
  enable_maintenance_mode    = false
  auth_provider              = "auth0"
  previous_auth_provider     = "gds_sso"
  cloudwatch_metrics_enabled = true
  analytics_enabled          = true
  act_as_user_enabled        = false
  govuk_app_domain           = "publishing.service.gov.uk"
  synchronize_to_mailchimp   = true
  repeatable_page_enabled    = false
}
forms_api_settings = {
  cpu          = 512
  memory       = 1024
  min_capacity = 6
  max_capacity = 36
}
forms_product_page_settings = {
  cpu          = 256
  memory       = 512
  min_capacity = 3
  max_capacity = 9
}
forms_runner_settings = {
  cpu                                                         = 1024
  memory                                                      = 2048
  min_capacity                                                = 6
  max_capacity                                                = 36
  enable_maintenance_mode                                     = false
  cloudwatch_metrics_enabled                                  = true
  analytics_enabled                                           = true
  csv_submission_enabled                                      = false
  csv_submission_enabled_for_form_ids                         = ["89", "143", "477", "696", "777", "1693", "1694", "1994", "2634", "2765", "3069", "3408", "4073"]
  allow_human_readonly_roles_to_assume_submissions_to_s3_role = false
}
scheduled_smoke_tests_settings = {
  enable_scheduled_smoke_tests = true
  form_url                     = "https://submit.forms.service.gov.uk/form/2570/scheduled-smoke-test"
  frequency_minutes            = 10
  enable_alerting              = true
}
