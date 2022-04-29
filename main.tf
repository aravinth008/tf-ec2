provider "aws" {
    region = "ap-south-1" 
#    access_key = "AKIATFIOM4K36WAPUJW5"
#    secret_key = "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"
}

#EC2
resource "aws_instance" "webinstance" {
    ami = "ami-0a3277ffce9146b74"
    instance_type = "t2.micro"
    availability_zone = "ap-south-1a"
    security_groups = [aws_security_group.webtraffic.name]
    key_name = "webkeypem-mumbai"
    user_data = <<-EOF
    #!/bin/bash
    yum install httpd -y
    echo "Hello i am form $(hostname -f)" > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
    EOF
    tags = {
      "Name" = "ec2-terraform"    
    } 
}

#EIP
resource "aws_eip" "elasticip" {
  instance = aws_instance.webinstance.id
}

#SG
resource "aws_security_group" "webtraffic" {
  name = "web-sg"
  #inbound
  ingress  {
    description = "Allow inbound http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    description = "Allow inbound SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound
  egress  {
    description = "Allow outbound any"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  } 
}

#resource "aws_key_pair" "pubkey" {
#  key_name = "webkeypem-mumbai"
#}

output "eip" {
  value = aws_eip.elasticip.public_ip 
}
