provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-07860a2d7eb515d9a" 
  instance_type = "t2.micro"

  tags = {
    Name = "ranjit-ec2"
  }
}
