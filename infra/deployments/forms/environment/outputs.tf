output "vpc_id" {
  value = module.environment.vpc_id
}

output "vpc_cidr_block" {
  value = module.environment.vpc_cidr_block
}

output "private_subnet_ids" {
  value = module.environment.private_subnet_ids
}