locals {
  kinesis_log_destination_eu_west_2_name = "kinesis-log-destination"
  kinesis_log_destination_eu_west_2_arn  = "arn:aws:logs:eu-west-2:${module.all_accounts.deploy_account_id}:destination:${local.kinesis_log_destination_eu_west_2_name}"

  kinesis_log_destination_us_east_1_name = "kinesis-log-destination-us-east-1"
  kinesis_log_destination_us_east_1_arn  = "arn:aws:logs:us-east-1:${module.all_accounts.deploy_account_id}:destination:${local.kinesis_log_destination_us_east_1_name}"
}

output "kinesis_log_destination_names" {
  value = {
    eu-west-2 = local.kinesis_log_destination_eu_west_2_name
    us-east-1 = local.kinesis_log_destination_us_east_1_name
  }
}

output "kinesis_log_destination_arns" {
  value = {
    eu-west-2 = local.kinesis_log_destination_eu_west_2_arn
    us-east-1 = local.kinesis_log_destination_us_east_1_arn
  }
}
