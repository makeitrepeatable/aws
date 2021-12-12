resource "random_string" "random" {
  length           = 5
  special          = false
  min_numeric = 2
}
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_inbound"
  description = "Allow inbound traffic on 22 & 443"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = var.tags
}

## Creating Launch Configuration
resource "aws_launch_configuration" "launch_config" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.allow_http_ssh.id]
  key_name        = aws_key_pair.webserver_key.key_name
  user_data       = <<-EOF
                        #!/bin/bash
                        sudo chown ubuntu /var/www/html
                        sudo chmod -R o+r /var/www/html
                        sudo rm -rf /var/www/html/index.html
                        echo "<html><h1>AWS EC2 ASG Example</h1></html><br /><img src=https://${aws_cloudfront_distribution.s3_distribution.domain_name}/checkout.png />" > /var/www/html/index.html
                      EOF
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.launch_config.id
  availability_zones   = data.aws_availability_zones.az.names
  min_size             = var.asg_min
  max_size             = var.asg_max
  load_balancers       = [aws_elb.elb_demo.name]
  health_check_type    = var.asg_health_check_type
  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}

## Security Group for ELB
resource "aws_security_group" "elb_sg" {
  name = var.asg_name
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb_demo" {
  name               = var.elb_name
  security_groups    = [aws_security_group.elb_sg.id]
  availability_zones = data.aws_availability_zones.az.names
  health_check {
    healthy_threshold   = var.elb_health_check.healthy_threshold
    unhealthy_threshold = var.elb_health_check.unhealthy_threshold
    timeout             = var.elb_health_check.timeout
    interval            = var.elb_health_check.interval
    target              = var.elb_health_check.target
  }
  listener {
    lb_port           = var.elb_listener.lb_port
    lb_protocol       = var.elb_listener.lb_protocol
    instance_port     = var.elb_listener.instance_port
    instance_protocol = var.elb_listener.instance_protocol
  }
}

output "elb_dns_name" {
  value = aws_elb.elb_demo.dns_name
}
