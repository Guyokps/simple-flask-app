# main.tf

provider "aws" {
  region = "us-east-1"
}

variable "create_instance" {
  type    = bool
  default = false  # Set this to false if you don't want to create the instance
}

data "aws_security_group" "existing_ssh_security_group" {
  name = "ssh-security-group"
}

resource "aws_instance" "example" {
  count         = var.create_instance ? 1 : 0  # Create the instance only if var.create_instance is true
  ami           = "ami-053b0d53c279acc90"  # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "terraform"
  tags = {
    Name = "TF Instance"
  }

  # Check if the security group already exists
  dynamic "security_group_ids" {
    for_each = data.aws_security_group.existing_ssh_security_group.id != null ? [data.aws_security_group.existing_ssh_security_group.id] : []
    content {
      value = security_group_ids.value
    }
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

# Create a security group only if it doesn't already exist
resource "aws_security_group" "ssh_security_group" {
  count        = data.aws_security_group.existing_ssh_security_group.id == null ? 1 : 0
  name         = "ssh-security-group"
  description  = "Allow SSH connections"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow connections from any IP address
  }
}
