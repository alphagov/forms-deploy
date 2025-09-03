module "secrets_spike_task" {
  source = "../../"

  name_prefix        = "dev-secrets-spike"
  region             = "eu-west-2"
  vpc_id             = "vpc-1234567890abcdef0"
  private_subnet_ids = ["subnet-111", "subnet-222"]
  security_group_ids = ["sg-abc123"]

  desired_count = 1
  cpu           = 256
  memory        = 512

  secrets = {
    catlike_arn = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:/spikesecrets/catlike/dummy-secret-AbCdEf"
    doglike_arn = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:/spikesecrets/doglike/dummy-secret-GhIjKl"
  }

  secrets_account_id = "123456789012"
}

output "example_outputs" {
  value = {
    catlike_lambda_name = module.secrets_spike_task.catlike_lambda_name
    doglike_lambda_name = module.secrets_spike_task.doglike_lambda_name
    catlike_rule_name   = module.secrets_spike_task.catlike_event_rule_name
    doglike_rule_name   = module.secrets_spike_task.doglike_event_rule_name
  }
}
