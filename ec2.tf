resource "aws_instance" "my_ec2" {
  ami = "ami-0947d2ba12ee1ff75"
  instance_type = "t2.micro"
}