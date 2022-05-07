provider "awsasdasd" {
  region = "us-east-1"
  profile = "boto3r"
}
locals {
  common_tags = {
    Name = "web_application_server"
    env = "dev"
    leader = "ops_team"
  }
}
  locals {
    common_cidrs = {
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

resource "aws_instance" "my_ec2" {
  ami = "ami-0947d2ba12ee1ff75"
  instance_type = "t2.micro"
  tags = local.common_tags
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
  user_data = file("web_app.sh")
}
resource "aws_security_group" "web_app_sg" {
  vpc_id = "vpc-e740ad9a"
  name="web_app_sg"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = local.common_cidrs.cidr_blocks
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = local.common_cidrs.cidr_blocks
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = local.common_cidrs.cidr_blocks
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = local.common_cidrs.cidr_blocks
  }
  tags = local.common_tags
}
output "ec2_details" {
  value = [aws_instance.my_ec2.public_ip, aws_security_group.web_app_sg.tags]
}
