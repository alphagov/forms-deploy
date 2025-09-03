module "all_accounts" {
  count = var.environment_type == "development" ? 1 : 0

  source = "../../../modules/all-accounts"
}

# Development-only: spike module to validate cross-account Secrets Manager access and redeploy
resource "aws_security_group" "secrets_spike" {
  count       = var.environment_type == "development" ? 1 : 0
  name        = "${var.environment_name}-secrets-spike"
  description = "Egress-only SG for secrets spike ECS tasks"
  vpc_id      = data.terraform_remote_state.forms_environment.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



locals {
  # Spike demonstration secrets (catlike/doglike approach)
  catlike_secret_arn = "arn:aws:secretsmanager:eu-west-2:711966560482:secret:/spikesecrets/catlike/dummy-secret-Ab0Yfc"
  doglike_secret_arn = "arn:aws:secretsmanager:eu-west-2:711966560482:secret:/spikesecrets/doglike/dummy-secret-r6ogL8"

  # Production approach: environment-scoped secret
  # This secret path will be accessible only by this environment account
  environment_secret_arn = "arn:aws:secretsmanager:eu-west-2:711966560482:secret:/spikesecrets/${var.environment_name}/fake-app/dummy-secret"
}

module "secrets_spike_task" {
  count  = var.environment_type == "development" ? 1 : 0
  source = "../../../modules/secrets-spike-task"

  name_prefix        = "${var.environment_name}-secrets-spike"
  region             = "eu-west-2"
  vpc_id             = data.terraform_remote_state.forms_environment.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.forms_environment.outputs.private_subnet_ids
  security_group_ids = aws_security_group.secrets_spike[*].id

  # Current spike approach using catlike/doglike
  secrets = {
    catlike_arn = local.catlike_secret_arn
    doglike_arn = local.doglike_secret_arn
  }

  secrets_account_id = module.all_accounts[count.index].deploy_account_id
}

# Note: In production, this would be replaced with environment-scoped secrets:
# The environment secret (local.environment_secret_arn) would be accessible
# by ANY role in this account due to the account-level principal policy.
# Example: ECS execution roles would automatically have access to
# "/spikesecrets/${var.environment_name}/**" secrets without additional policies.
