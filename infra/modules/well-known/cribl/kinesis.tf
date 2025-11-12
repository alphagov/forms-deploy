locals {
  kinesis_destination_names = {
    "eu-west-2" = "kinesis-log-destination"
    "us-east-1" = "kinesis-log-destination-us-east-1"
  }
}

output "kinesis_destination_names" {
  description = "The names of the kinesis log destinations per region"
  value       = local.kinesis_destination_names
}

output "kinesis_destination_arns" {
  description = "The ARNs of the kinesis log destinations per region"
  value = {
    for region, name in local.kinesis_destination_names :
    region => "arn:aws:logs:${region}:${module.all_accounts.deploy_account_id}:destination:${name}"
  }
}
