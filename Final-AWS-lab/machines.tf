#Write User Data
data "template_file" "user_data" {
  template = <<-EOF
    #!/bin/bash
    sudo apt update -y 
    sudo apt install apache2 -y 
    sudo systemctl start apache2
    sudo systemctl enable apache2
  EOF
}

#Create Ubuntu Launch Template
resource "aws_launch_template" "web-template" {
  name_prefix   = "web-template"
  image_id      = var.SRV_IMG
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  user_data              = base64encode(data.template_file.user_data.rendered)
  key_name      = "nti-aws"
}


#Create TargetGroup
resource "aws_lb_target_group" "web-tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC-NTI.id
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



#Create Load-Balancer
resource "aws_lb" "web-lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  #specify your subnets to attach them to load-balancer
  subnets            = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id, aws_subnet.public-subnet3.id]  
}

#Add LB listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
  
}

#Create AutoScalingGroup
resource "aws_autoscaling_group" "web-ASG" {
  name                      = "web-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id, aws_subnet.private-subnet3.id]
  launch_template {
    id      = aws_launch_template.web-template.id
    version = "$Latest"
  } 
  # Attach the target group
  target_group_arns = [aws_lb_target_group.web-tg.arn]
}


#Attach auto scaling policy to auto scaling group
resource "aws_autoscaling_policy" "network_scaling_policy" {
  name                   = "scale-policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300  # Adjust this value as needed
  autoscaling_group_name = aws_autoscaling_group.web-ASG.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageNetworkIn"
    }

    target_value = 85.0
  }
}

