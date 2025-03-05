data "aws_vpc" "vpc" {
  tags = {
    Name = "forms-${var.environment}"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private-*"]
  }
}
