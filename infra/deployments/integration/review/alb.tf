module "alb" {
  source = "./alb"

  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  subnet_ids         = module.vpc.public_subnet_ids
  send_logs_to_cyber = var.send_logs_to_cyber

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  kinesis_subscription_role_arn = data.terraform_remote_state.account.outputs.kinesis_subscription_role_arn
}
