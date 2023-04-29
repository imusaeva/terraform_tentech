# create VPC:
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24" # 256
  # instance_tenancy = "default" - optional

  tags = {
    Name = "second_lession_vpc"
  }
}

#lookup available az in the region:
data "aws_availability_zones" "azs" {
  state = "available"
}

# create public-1a subnet:
resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.vpc.id # resource type.resourse name.resource attribute
  cidr_block              = "10.0.0.0/26"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-1a"
  }
}

# create public-1b subnet:
resource "aws_subnet" "public-1b" {
  vpc_id                  = aws_vpc.vpc.id # resource type.resourse name.resource attribute
  cidr_block              = "10.0.0.64/26"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true


  tags = {
    Name = "public-1b"
  }
}

# create private-1a subnet:
resource "aws_subnet" "private-1a" {
  vpc_id                  = aws_vpc.vpc.id # resource type.resourse name.resource attribute
  cidr_block              = "10.0.0.128/26"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-1a"
  }
}

# create private-1b subnet:
resource "aws_subnet" "private-1b" {
  vpc_id                  = aws_vpc.vpc.id # resource type.resourse name.resource attribute
  cidr_block              = "10.0.0.192/26"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-1b"
  }
}

# create IGW :
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-second-lesson"
  }
}

# create EIP:
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "nat_eip"
  }
}

# create NAT :
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-1a.id

  tags = {
    Name = "natgw"
  }
  depends_on = [ # to make sure right order for nat creation
    aws_eip.nat_eip
  ]
}

# create public route table:
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

# create private route table:
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-rtb"
  }
}

# associate public rtb with pub-1a:
resource "aws_route_table_association" "public-1a-rtb-aws_route_table_association" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public-rtb.id
}

# associate public rtb with pub-1b:
resource "aws_route_table_association" "public-1b-rtb-aws_route_table_association" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public-rtb.id
}

# associate private rtb with priv-1a:
resource "aws_route_table_association" "private-1a-rtb-aws_route_table_association" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private-rtb.id
}

# associate private rtb with priv-1b:
resource "aws_route_table_association" "private-1b-rtb-aws_route_table_association" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private-rtb.id
}

# create EC2:
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon-linux-2_ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-1a.id
  key_name               = data.aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.public-sg.id]

  user_data = <<EOT
  #!/bin/bash
  yum update -y
  yum install httpd -y
  echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html 
  systemctl start httpd
  systemctl enable httpd
  EOT

  tags = {
    Name = "public_1a_ec2"
  }
}