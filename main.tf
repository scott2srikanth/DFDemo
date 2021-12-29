provider "aws"{
    region = var.region[0]
}

resource "aws_instance" "myinstance"{
    ami = var.ami
    instance_type = var.Itypes["us-east-2"]
    tags = {
      Name = "JenkeinInstance"
    }
    key_name = "mykey"
    vpc_security_group_ids  = [aws_security_group.allow_all.id]

   provisioner "remote-exec" {
     inline = [
      "sudo yum update -y",
        "sudo yum install java-1.8.0 -y",
        "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo",
        "sudo amazon-linux-extras install epel -y",
        "sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key",
        "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl status jenkins",
      "sleep 60",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
     ]
   }

   
   
   connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("./mykey.pem")
     host = self.public_ip
   }
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow SSH inbound traffic"

   ingress {
      description      = "TCP from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress {
      description = "SSH into VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      description = "Outbound Allowed"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_eip" "lb" {
  vpc = true
}

output "eip" {
  value = aws_eip.lb.public_ip
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.myinstance.id
  allocation_id = aws_eip.lb.id
}