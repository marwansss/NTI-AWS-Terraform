#SecurityGroups & Policies for EC2
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

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = var.HTTPS
  ip_protocol       = "tcp"
  to_port           = var.HTTPS
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

#-----------------------------------------------------------------------------------------

#SecurityGroups & Policies for Load-Balancer
resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Allow http inbound traffic "
  vpc_id      = aws_vpc.VPC-NTI.id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb-allow_http_ipv4" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = var.HTTP
  ip_protocol       = "tcp"
  to_port           = var.HTTP
}


resource "aws_vpc_security_group_egress_rule" "lb-allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = var.DEST_CIDR
  ip_protocol       = "-1" 
}

#--------------------------------------------------------------------------------------------------
