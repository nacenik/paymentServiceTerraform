provider "aws" {}

resource "aws_security_group" "security_for_my_server" {
  name        = "my_security_group"
  description = "all for my server"

  ingress {
    description = "server port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["194.143.145.130/32"]
  }

  ingress {
    description      = "https-ipv4"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "data base port"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Payment system security group"
  }
}


resource "aws_instance" "my_linux" {
  ami           = "ami-04902260ca3d33422"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.security_for_my_server.id]

  user_data = <<-EOT
#!/bin/bash
sudo yum update -y
sudo yum install -y docker
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
AKIAVQJWDT3DGEIBN3OI
4ydcTsShQnKn4jQfni0q0229MDsTa6VenR1eNA3p
sudo service docker start
sudo docker pull nacenik/stage-payment-system-aws:v2
sudo docker run -d -p 8080:8080 nacenik/stage-payment-system-aws:v2


  EOT

  tags = {
    Name = "Payment system"
  }

  key_name = "nacenik-test"
}

resource "aws_db_instance" "payment-system" {
  identifier             = "payment-system"
  instance_class         = "db.t2.micro"
  engine                 = "postgres"
  engine_version         = "12.8"
  username               = "postgres"
  password               = "11111111"
  port                   = "5432"
  vpc_security_group_ids = [aws_security_group.security_for_my_server.id]
  skip_final_snapshot    = false

}

resource "aws_s3_bucket" "payment" {
  bucket = "nacenik-pament-system-backet"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
