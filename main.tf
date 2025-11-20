provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0fa3fe0fa7920f68e" 
  instance_type = "t3.micro"

  tags = {
    Name = "ranjit-ec2"
  }
}
