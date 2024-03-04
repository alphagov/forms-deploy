
resource "aws_eip" "nat_ip" {
  #checkov:skip=CKV2_AWS_19:Checkov error, EIP is allocated to Nat Gateway
  for_each = toset(["eu-west-2a", "eu-west-2b", "eu-west-2c"])

  tags = {
    Name = "tools-eip-${each.value}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.nat_subnets
  allocation_id = aws_eip.nat_ip[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}
