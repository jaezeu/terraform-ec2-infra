resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon2023.id
  instance_type               = "t2.micro"
  subnet_id                   = flatten(data.aws_subnets.public.ids)[0] #ID of 1 of the public subnets
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  iam_instance_profile        = aws_iam_instance_profile.example.name
  user_data                   = <<EOF
#!/bin/bash
sudo su
yum install git -y
yum install docker -y
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
systemctl start docker
EOF
  user_data_replace_on_change = true # this forces instance to be recreated upon update of user data contents

  tags = {
    Name = "jazeel-ec2" #Change to a name you would want your ec2 to be called
  }
}

resource "aws_security_group" "sg" {
  name        = "jazeel-security-group"
  description = "Allow SSH inbound and all outbound"
  vpc_id      = data.aws_vpc.selected.id #VPC Id of the default VPC
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

