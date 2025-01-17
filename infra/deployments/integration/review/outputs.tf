output "vpc_id" {
  description = "The id of the VPC in which the review apps resources exist"
  value       = module.vpc.vpc_id
}
