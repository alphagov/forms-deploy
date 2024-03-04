resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tools.id

  tags = {
    Name = "tools-igw"
  }
}

resource "aws_subnet" "alb_subnets" {
  for_each = {
    "eu-west-2a" : "10.0.1.0/24",
    "eu-west-2b" : "10.0.2.0/24",
    "eu-west-2c" : "10.0.3.0/24"
  }

  vpc_id            = aws_vpc.tools.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "alb-${each.key}"
  }
}

resource "aws_subnet" "nat_subnets" {
  for_each = {
    "eu-west-2a" : "10.0.4.0/24",
    "eu-west-2b" : "10.0.5.0/24",
    "eu-west-2c" : "10.0.6.0/24"
  }

  vpc_id            = aws_vpc.tools.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "nat-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tools.id
  tags = {
    Name = "public"
  }
}

resource "aws_route" "to_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "alb_subnet_to_igw" {
  for_each       = aws_subnet.alb_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "nat_subnet_to_igw" {
  for_each       = aws_subnet.nat_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
