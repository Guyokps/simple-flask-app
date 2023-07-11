# main.tf

provider "aws" {
  region = "us-east-1"
}

variable "create_instance" {
  type    = bool
  default = true  # Set this to false if you don't want to create the instance
}

resource "aws_security_group" "ssh" {
  name        = "ssh-security-group"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  count         = var.create_instance ? 1 : 0
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = "terraform"

  tags = {
    Name = "FlaskApp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install docker.io -y",
      "sudo systemctl restart docker",
      "sudo systemctl enable docker",
      "sudo docker pull guyok3/flask-app",
      "sudo docker run -p 80:5000 -d flask-app"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("terraform.pem")
  }
}