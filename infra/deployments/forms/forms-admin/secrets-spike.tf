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

module "secrets_spike_task" {
  count  = var.environment_type == "development" ? 1 : 0
  source = "../../../modules/secrets-spike-task"

  name_prefix        = "${var.environment_name}-secrets-spike"
  region             = "eu-west-2"
  vpc_id             = data.terraform_remote_state.forms_environment.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.forms_environment.outputs.private_subnet_ids
  security_group_ids = aws_security_group.secrets_spike[*].id

  secrets = {
    catlike_arn = var.spike_catlike_secret_arn
    doglike_arn = var.spike_doglike_secret_arn
  }

  secrets_account_id = module.all_accounts[count.index].deploy_account_id
}

## inputs



##
# Spike (development-only)
##
variable "spike_catlike_secret_arn" {
  description = "Full ARN of the /spikesecrets/catlike/dummy-secret in the central secrets account"
  type        = string
  default     = null
}

variable "spike_doglike_secret_arn" {
  description = "Full ARN of the /spikesecrets/doglike/dummy-secret in the central secrets account"
  type        = string
  default     = null
}
