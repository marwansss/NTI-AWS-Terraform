resource "aws_vpc" "VPC-NTI" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "VPC-NTI"
  }
}


resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.VPC-NTI.id
  cidr_block = "10.0.1.0/24"
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


resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.VPC-NTI.id
   tags = {
    Name = "public-rt"
  }
  }


  resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}



resource "aws_route_table_association" "subnet-ass" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
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
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ping_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}


resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}



resource "aws_instance" "web1" {
  ami           = "ami-080e1f13689e07408" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id
  associate_public_ip_address = true

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

#resource "aws_s3_bucket" "S3_bucket" {
#  bucket = "maro-s3"
#  tags = {
 #   Name        = "Terraform-State"
 #    Environment = "Dev"
 # }
#}

##Create DynamoDB table Before intialize the s3 backend
#terraform {
#  backend "s3" {
#    bucket         = "maro-s3"
#    key            = "dev/statefil"
#    region = "us-east-1"
#    dynamodb_table = "terraform"
#  }
#}
#LockID is the key of the dynamodb
