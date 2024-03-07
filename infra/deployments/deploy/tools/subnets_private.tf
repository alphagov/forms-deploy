resource "aws_route_table" "private" {
  for_each = toset(["eu-west-2a", "eu-west-2b", "eu-west-2c"])
  vpc_id   = aws_vpc.tools.id
  tags = {
    Name = "private-${each.value}"
  }
}

resource "aws_route" "pipeline_visualiser_to_nat_gateway" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_subnet" "pipeline_visualiser_subnets" {
  for_each = {
    # One /24 divided into 3
    "eu-west-2a" : "10.0.10.0/26",
    "eu-west-2b" : "10.0.10.64/26",
    "eu-west-2c" : "10.0.10.128/26"
  }

  vpc_id            = aws_vpc.tools.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "pipeline-visualiser-${each.key}"
  }
}

resource "aws_route_table_association" "pipeline_visualiser_subnets" {
  for_each       = aws_subnet.pipeline_visualiser_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
