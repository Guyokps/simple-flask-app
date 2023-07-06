# main.tf

provider "aws" {
  region = "us-east-1"
}

variable "create_instance" {
  type    = bool
  default = false  # Set this to false if you don't want to create the instance
}

resource "aws_instance" "example" {
  count         = var.create_instance ? 1 : 0  # Create the instance only if var.create_instance is true
  ami           = "ami-053b0d53c279acc90"  # Replace with the desired AMI ID
  instance_type = "t2.micro"
  key_name      = "terraform"
  #security_group_ids = ["<your_security_group_id>"]
  tags = {
    Name = "TF Instance"
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
