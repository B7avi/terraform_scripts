provider "aws" {
  region  = "us-east-1"
  profile = "boto3r"
}
#creating dev instance
resource "aws_instance" "my_instance1" {
  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = "t2.micro"
  user_data              = file("dev.sh")
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.aws_SG.id]
}
#creating test instance
resource "aws_instance" "my_instance2" {
  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = "t2.micro"
  user_data              = file("test.sh")
  availability_zone      = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.aws_SG.id]
}
#creating prod instance
resource "aws_instance" "my_instance3" {
  ami                    = "ami-0947d2ba12ee1ff75"
  instance_type          = "t2.micro"
  user_data              = file("prod.sh")
  availability_zone      = "us-east-1c"
  vpc_security_group_ids = [aws_security_group.aws_SG.id]
}
#creating security groups for the instances
resource "aws_security_group" "aws_SG" {
  name   = "web_sg"
  vpc_id = "vpc-e740ad9a"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#creating sg for alb
resource "aws_security_group" "aws_ALB" {
  name   = "alb_sg"
  vpc_id = "vpc-e740ad9a"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# crearting LB
resource "aws_lb" "ALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws_ALB.id]
  subnets            = ["subnet-1a7dac7c", "subnet-2f37e80e", "subnet-75c01d2a"]
}
#creating lb listner
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.my_tg.arn
  }
}
#creating target groupfor alb
resource "aws_alb_target_group" "my_tg" {
  name        = "mytg"
  vpc_id      = "vpc-e740ad9a"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  health_check {
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200" # has to be HTTP 200 or fails
  }
}
resource "aws_alb_target_group_attachment" "my_alb_TG_ATTACH1" {
  target_group_arn = aws_alb_target_group.my_tg.arn
  target_id        = aws_instance.my_instance1.id
}
resource "aws_alb_target_group_attachment" "my_alb_TG_ATTACH2" {
  target_group_arn = aws_alb_target_group.my_tg.arn
  target_id        = aws_instance.my_instance2.id
}
resource "aws_alb_target_group_attachment" "my_alb_TG_ATTACH3" {
  target_group_arn = aws_alb_target_group.my_tg.arn
  target_id        = aws_instance.my_instance3.id
}
output "alb_end" {
  value = aws_lb.ALB.dns_name
}



