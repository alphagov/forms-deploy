output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "private_subnet_cidr_blocks" {
  value = [for s in aws_subnet.private : s.cidr_block]
}

output "nat_gateway_egress_ips" {
  value = [for eip in aws_eip.nat_eip : eip.public_ip]
}
