variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names"
}

variable "cloudfront_arn" {
  type        = string
  description = "The ARN of our CloudFront"
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "The distribution ID of our CloudFront"
}

variable "alb_arn" {
  type        = string
  description = "The ARN of our Application Load Balancer"
}

variable "alb_log_bucket_name" {
  type        = string
  description = "The S3 log bucket name for where we store our ALB logs"
}

variable "alb_name" {
  type        = string
  description = "The name of our Application Load Balancer"
}
