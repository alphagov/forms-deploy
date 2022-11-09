resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.forms.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "private-a-${var.env_name}"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.forms.id
  tags = {
    Name = "private-${var.env_name}"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route" "to_nat_gateway_a" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.forms.id
  cidr_block        = "10.10.5.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "private-b-${var.env_name}"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.forms.id
  tags = {
    Name = "private-b-${var.env_name}"
  }
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_route" "to_nat_gateway_b" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.forms.id
  cidr_block        = "10.10.6.0/24"
  availability_zone = "eu-west-2c"
  tags = {
    Name = "private-c-${var.env_name}"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.forms.id
  tags = {
    Name = "private-c-${var.env_name}"
  }
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

resource "aws_route" "to_nat_gateway_c" {
  route_table_id         = aws_route_table.private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_c.id
}

