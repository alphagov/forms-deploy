locals {
  # Public and private ranges are broken into
  # /24 blocks (VPCs /16 + 8; 256 addresses each)
  #
  # Public subnets will likely only contain ALBs and
  # NAT gateways, which are unlikely to fill 256 IP
  # addresses.
  #
  # The private ranges come afterwards, so that they
  # can expand into the unallocated space if we need
  # them to.
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  public_ranges = {
    for i, zone in local.availability_zones :
    zone => cidrsubnet(aws_vpc.vpc.cidr_block, 8, i + 1)
  }

  private_ranges = {
    for i, zone in local.availability_zones :
    zone => cidrsubnet(aws_vpc.vpc.cidr_block, 8, (i + 1 + length(local.availability_zones)))
  }
}

##
# Internet gateways & NAT gateways
##
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "review"
  }
}

resource "aws_eip" "nat_eip" {
  #checkov:skip=CKV2_AWS_19:Checkov error, EIP is allocated to Nat Gateway
  for_each = toset(local.availability_zones)
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = toset(local.availability_zones)

  allocation_id = aws_eip.nat_eip[each.value].id
  subnet_id     = aws_subnet.private[each.value].id

  tags = {
    Name = "review-${each.value}"
  }
}
##
# Subnets
##
resource "aws_subnet" "public" {
  for_each = toset(local.availability_zones)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public_ranges[each.value]
  availability_zone = each.value

  tags = {
    Name = "review-public-${each.value}"
  }
}

resource "aws_subnet" "private" {
  for_each = toset(local.availability_zones)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_ranges[each.value]
  availability_zone = each.value

  tags = {
    Name = "review-private-${each.value}"
  }
}

##
# Public route table
##
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "review-public"
  }
}

resource "aws_route" "to_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

##
# Private route table
# (n.b. 1 route table per subnet)
##
resource "aws_route_table" "private" {
  for_each = toset(local.availability_zones)

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "review-private-${each.value}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.availability_zones)

  route_table_id = aws_route_table.private[each.value].id
  subnet_id      = aws_subnet.private[each.value].id
}

resource "aws_route" "to_nat_gw" {
  for_each = toset(local.availability_zones)

  route_table_id         = aws_route_table.private[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.value].id
}
