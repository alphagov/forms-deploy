output "vpc_id" {
  value = aws_vpc.forms.id
}

output "vpc_cidr_block" {
  value = aws_vpc.forms.cidr_block
}

output "private_subnet_ids" {
  value = {
    "a" = aws_subnet.private_a.id
    "b" = aws_subnet.private_b.id
    "c" = aws_subnet.private_c.id
  }
}