#Create public TargetGroup
resource "aws_lb_target_group" "proxy-tg" {
  name     = "proxy-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  load_balancing_algorithm_type = "round_robin"
  target_type = "instance"
  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  } 

}

#attaching ec2 to proxy-tg target group
resource "aws_lb_target_group_attachment" "proxy_attach" {
  count = length(var.proxy-server-id)
  target_group_arn = aws_lb_target_group.proxy-tg.arn
  target_id        = var.proxy-server-id[count.index]
  port             = 80
}



#Create public Load-Balancer
resource "aws_lb" "proxy-lb" {
  name               = "proxy-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  #specify your subnets to attach them to load-balancer
  subnets            =  var.proxy-lb-subnets
}

#Add LB listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.proxy-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy-tg.arn
  }
  
}


#SecurityGroups & Policies for Load-Balancer
resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Allow http inbound traffic "
  vpc_id      = var.vpc_id

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


resource "aws_vpc_security_group_egress_rule" "lb-allow_http_ipv4" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = var.DEST_CIDR
  from_port         = var.HTTP
  ip_protocol       = "tcp"
  to_port           = var.HTTP
}


#--------------------------------------------------------------------------

#Create private TargetGroup for apache-servers
resource "aws_lb_target_group" "apache-tg" {
  name     = "apache-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  load_balancing_algorithm_type = "round_robin"
  target_type = "instance"
  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  } 

}

#attaching ec2 to apache-tg target group
resource "aws_lb_target_group_attachment" "apache_attach" {
  count = length(var.apache-server-id)
  target_group_arn = aws_lb_target_group.apache-tg.arn
  target_id        = var.apache-server-id[count.index]
  port             = 80
}



#Create private Load-Balancer
resource "aws_lb" "apache-lb" {
  name               = "apache-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  #specify your subnets to attach them to load-balancer
  subnets            =  var.apache-lb-subnets
}

#Add LB listener
resource "aws_lb_listener" "private-http" {
  load_balancer_arn = aws_lb.apache-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache-tg.arn
  }
  
}


