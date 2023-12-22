account_name     = "production"
aws_account_id   = "443944947292"
environment_type = "production"
apex_domain      = "forms.service.gov.uk"
dns_delegation_records = {
  "dev.forms.service.gov.uk" = [
    "ns-124.awsdns-15.com",
    "ns-1371.awsdns-43.org",
    "ns-2043.awsdns-63.co.uk",
    "ns-593.awsdns-10.net",
  ],

  "staging.forms.service.gov.uk" = [
    "ns-1162.awsdns-17.org",
    "ns-1604.awsdns-08.co.uk",
    "ns-359.awsdns-44.com",
    "ns-638.awsdns-15.net",
  ],

  "research.forms.service.gov.uk" = [
    "ns-1068.awsdns-05.org",
    "ns-1742.awsdns-25.co.uk",
    "ns-279.awsdns-34.com",
    "ns-950.awsdns-54.net",
  ]
}

# Remove this once the zone has been imported
existing_hosted_zone_id = "Z029841414A29LF7J7EDY"