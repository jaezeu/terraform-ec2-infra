resource "aws_instance" "public" {
  ami                         = "ami-04c913012f8977029"   #amazonlinux in sg region
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0cc94b815da8f0c95"   #ID of 1 of the public subnets
  associate_public_ip_address = true
  key_name                    = "jazeel-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  
  tags = {
    Name = "jazeel-ec2"    #Change to a name you would want your ec2 to be called
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "jazeel-security-group"
  description = "Allow SSH inbound and all outbound"
  vpc_id      = "vpc-071f8836040c9beba"  #VPC Id of the default VPC
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "116.89.1.215/32"   #Add your own public IP here. Get it from whatismyip.com. Add /32
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}