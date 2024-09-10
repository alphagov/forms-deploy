output "vpc_id" {
  value = module.environment.vpc_id
}

output "vpc_cidr_block" {
  value = module.environment.vpc_cidr_block
}

output "private_subnet_ids" {
  value = module.environment.private_subnet_ids
}

output "cloudfront_arn" {
  value = module.environment.cloudfront_arn
}

output "cloudfront_distribution_id" {
  value = module.environment.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  value = module.environment.cloudfront_domain_name
}

output "cloudfront_hosted_zone_id" {
  value = module.environment.cloudfront_hosted_zone_id
}