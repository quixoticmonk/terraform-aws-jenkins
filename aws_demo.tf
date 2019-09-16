provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "aws_instance" "jenkins_ec2" {
  ami = "ami-0520e698dd500b1d1"
  instance_type = "t2.micro"
  key_name = var.key_name
  security_groups = [
    aws_security_group.jenkins_sg.name]

  tags = {
    Name = "JENKINS_MASTER"
  }


  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = aws_instance.jenkins_ec2.public_dns
      private_key = file(var.private_key_path)
      timeout = "2m"

    }
    inline = [
      "sudo yum update -yes",
      "sudo yum install wget -y",
      "sudo yum install -y java-1.8.0-openjdk.x86_64",
      "sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java",
      "sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo",
      "sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
      "sudo yum install jenkins -y",
      "sudo service jenkins start",
      "sudo chkconfig --add jenkins",
      "sudo more /var/log/jenkins.log"
    ]
  }
}

resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"
  description = "Security Group for Jenkins"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.dest_cidr_block]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.dest_cidr_block]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [var.dest_cidr_block]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

####################################################################################
# OUTPUT
####################################################################################

output "aws_instance_public_dns" {
  value = aws_instance.jenkins_ec2.public_dns
}


