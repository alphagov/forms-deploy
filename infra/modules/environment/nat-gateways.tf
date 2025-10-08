resource "aws_eip" "nat_a" {
  #checkov:skip=CKV2_AWS_19:Checkov error, EIP is allocated to Nat Gateway
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "nat-a"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat_b" {
  #checkov:skip=CKV2_AWS_19:Checkov error, EIP is allocated to Nat Gateway
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "nat-b"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat_c" {
  #checkov:skip=CKV2_AWS_19:Checkov error, EIP is allocated to Nat Gateway
}

resource "aws_nat_gateway" "nat_c" {
  allocation_id = aws_eip.nat_c.id
  subnet_id     = aws_subnet.public_c.id

  tags = {
    Name = "nat-c"
  }

  depends_on = [aws_internet_gateway.gw]
}
