resource "aws_route_table" "public" {
  vpc_id = aws_vpc.forms.id
  tags = {
    Name = "public-${var.env_name}"
  }
}

resource "aws_route" "to_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.forms.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "public-a-${var.env_name}"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.forms.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "public-b-${var.env_name}"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.forms.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "eu-west-2c"
  tags = {
    Name = "public-c-${var.env_name}"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

