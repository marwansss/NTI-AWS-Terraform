resource "aws_vpc" "VPC-NTI" {
  cidr_block       = var.VPC_CIDR
  tags = {
    Name = "VPC-NTI"
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PRIVATE_SUBNET_CIDR
   tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = var.PUBLIC_SUBNET_CIDR
   tags = {
    Name = "public-subnet"
  }
}

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
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}



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



resource "aws_route_table_association" "subnet-ass" {
  subnet_id      = aws_subnet.public-subnet.id
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



resource "aws_route_table_association" "PrivateSubnet-ass" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}




resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow http inbound traffic "
  vpc_id      = aws_vpc.VPC-NTI.id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = var.SSH
  ip_protocol       = "tcp"
  to_port           = var.SSH
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = var.HTTP
  ip_protocol       = "tcp"
  to_port           = var.HTTP
}

resource "aws_vpc_security_group_ingress_rule" "allow_ping_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = var.DEST_CIDR
  ip_protocol       = "-1" 
}



resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = var.HTTPS
  ip_protocol       = "tcp"
  to_port           = var.HTTPS
}

resource "aws_instance" "web1" {
  ami           = var.SRV_IMG
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private-subnet.id
  key_name = "nti-aws"
   user_data              = <<-EOF
    #!/bin/bash
    sudo apt update -y 
    sudo apt install apache2 -y 
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOF 
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "web1"
  }

}


