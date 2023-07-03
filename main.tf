provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-053b0d53c279acc90"  # Replace with the desired AMI ID
  instance_type = "t2.micro"
}
