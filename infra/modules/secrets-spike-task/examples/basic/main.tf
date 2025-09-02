module "secrets_spike_task" {
  source = "../../"

  name_prefix        = "secrets-spike"
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

  secrets_account_id = "210987654321"

  # container_image can be omitted to use public busybox
  # container_image = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/secrets-spike:latest"
}
