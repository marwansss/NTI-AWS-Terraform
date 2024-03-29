#Create VPC
resource "aws_vpc" "VPC-NTI" {
  cidr_block       = var.VPC_CIDR
  tags = {
    Name = "VPC-NTI"
  }
}

#------------------------------------------------------------

#Create Subnets in different zones for High Availability
resource "aws_subnet" "private-subnet1" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PRIVATE_SUBNET1_CIDR
  availability_zone = "us-east-1a"
   tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PRIVATE_SUBNET2_CIDR
  availability_zone = "us-east-1b"
   tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "private-subnet3" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PRIVATE_SUBNET3_CIDR
  availability_zone = "us-east-1c"
   tags = {
    Name = "private-subnet"
  }
}


resource "aws_subnet" "public-subnet1" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PUBLIC_SUBNET1_CIDR
  availability_zone = "us-east-1a"
   tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PUBLIC_SUBNET2_CIDR
  availability_zone = "us-east-1b"
   tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "public-subnet3" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PUBLIC_SUBNET3_CIDR
  availability_zone = "us-east-1c"
   tags = {
    Name = "public-subnet"
  }
}

#--------------------------------------------------------

#Create gateways
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC-NTI.id

  tags = {
    Name = "nti-GW"
  }
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#--------------------------------------------------------------

#Create Routing Tables
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.VPC-NTI.id
   tags = {
    Name = "public-rt"
  }
  }


  resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = var.DEST_CIDR
  gateway_id             = aws_internet_gateway.gw.id
}



resource "aws_route_table_association" "subnet-ass1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "subnet-ass2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "subnet-ass3" {
  subnet_id      = aws_subnet.public-subnet3.id
  route_table_id = aws_route_table.public-rt.id
}




resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.VPC-NTI.id
   tags = {
    Name = "private-rt"
  }
  }


  resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = var.DEST_CIDR
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
}


#private-subnet1 Association
resource "aws_route_table_association" "PrivateSubnet1-ass" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private-rt.id
}

#private-subnet2 Association
resource "aws_route_table_association" "PrivateSubnet2-ass" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-rt.id
}

#private-subnet3 Association
resource "aws_route_table_association" "PrivateSubnet3-ass" {
  subnet_id      = aws_subnet.private-subnet3.id
  route_table_id = aws_route_table.private-rt.id
}

#----------------------------------------------------------------------











