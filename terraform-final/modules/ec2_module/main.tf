# Getting ec2 OS image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]  
  }
  filter {
  name   = "virtualization-type"
  values = ["hvm"]  
}
  filter {
  name   = "architecture"
  values = ["x86_64"]  
}
  owners = ["099720109477"]
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#creating security groups for web servers
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow necessary  traffic for webservers "
  vpc_id      = var.vpc-id # getting vpc-id value from the output resource declared in infrastructure module
  tags = {
    Name = "web-sg"
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

#-------------------------------------------------------------------------------------------------------------------------------------------------------

# Creating apache-webservers in provate subnets
resource "aws_instance" "apache_servers" {
  count = length(var.private_subnets_ids)
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = var.private_subnets_ids[count.index]
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
    Name = "webserver${count.index}"
  }
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------

# Creating proxy-servers
resource "aws_instance" "proxy-servers" {
  count = length(var.public_subnets_ids)
  ami           = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets_ids[count.index]
  key_name = "nti-aws"
   user_data              = <<-EOF
    #!/bin/bash
    sudo apt update -y 
    sudo wget http://nginx.org/keys/nginx_signing.key
    sudo apt-key add nginx_signing.key
    echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ focal nginx" > /etc/apt/sources.list.d/nginx.list
    sudo apt update -y 
    sudo apt install nginx -y 
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo echo '''
    upstream backend_servers {
      #Add webservers ip here OR internal LoadBalancer DNS Name
      # egs: server 10.0.0.0:80;
      # egs: internal-apache-lb-303911939.us-east-1.elb.amazonaws.com
    } 
    # Server block for handling incoming requests
    server {
      listen 80;
      listen [::]:80;
      #Add our proxy server ip here
      server_name localhost;

      location / {
        # Use proxy_pass to forward requests to the backend_servers upstream group
        proxy_pass http://backend_servers;
      }
    }
    ''' > /etc/nginx/conf.d/proxy.conf
    sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
  EOF 
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "proxy-server${count.index}"
  }  
}