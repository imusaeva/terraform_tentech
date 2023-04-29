# create vpc:
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "third_lesson_vpc"
  }
}

# lookup available azs in my region:
data "aws_availability_zones" "azs" {
  state = "available"
}

# create public-1a subnet:
resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-1a"
  }
}

# create public-1b subnet:
resource "aws_subnet" "public-1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-1b"
  }
}

# create private-1a subnet:
resource "aws_subnet" "private-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.128/26"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-1a"
  }
}

# create private-1b subnet:
resource "aws_subnet" "private-1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.192/26"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-1b"
  }
}

# create igw:
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "third_lesson_igw"
  }
}

# create natgw_eip:
resource "aws_eip" "natgw_eip" {
  vpc = true

  tags = {
    Name = "natgw_eip"
  }
}

# create natgw:
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = aws_subnet.public-1a.id
  depends_on    = [aws_eip.natgw_eip]

  tags = {
    Name = "natgw"
  }
}

# create public rtb:
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

# create private rtb:
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

# assoc public rtb with public-1a:
resource "aws_route_table_association" "public-1a-rtb-assoc" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id      = aws_subnet.public-1a.id
}

# assoc public rtb with public-1b:
resource "aws_route_table_association" "public-1b-rtb-assoc" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id      = aws_subnet.public-1b.id
}

# assoc private rtb with private-1a:
resource "aws_route_table_association" "private-1a-rtb-assoc" {
  route_table_id = aws_route_table.private-rtb.id
  subnet_id      = aws_subnet.private-1a.id
}

# assoc private rtb with private-1b:
resource "aws_route_table_association" "private-1b-rtb-assoc" {
  route_table_id = aws_route_table.private-rtb.id
  subnet_id      = aws_subnet.private-1b.id
}

# public sg for ec2:
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "allow 22 and 80 for www"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "allow http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all of them
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }
}

# lookup my ssh key:
data "aws_key_pair" "my_key" {
  key_name = "tentek"
}

# lookup latest amazon-linux-2 AMIs:
data "aws_ami" "amazon-linux-2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# launch an EC2 instance:
resource "aws_instance" "public_1a_ec2" {
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

# launch an EC2 instance:
resource "aws_instance" "public_1b_ec2" {
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
    Name = "public_1b_ec2"
  }
}

# to create an output info for resources : 
output "public-1a-ec2-public-ip" {
  value = aws_instance.public_1a_ec2.public_ip
}

output "public-public_1b_ec2-ec2-public-ip" {
  value = aws_instance.public_1b_ec2.public_ip
}

# create target group of ec2 for LB:
resource "aws_lb_target_group" "public-tg" {
  name     = "public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

# attach public-1a ec2 with tg:
resource "aws_lb_target_group_attachment" "public_1a_ec2-to-public-tg" {
  target_group_arn = aws_lb_target_group.public-tg.arn
  target_id        = aws_instance.public_1a_ec2.id
}
resource "aws_lb_target_group_attachment" "public_1b_ec2-to-public-tg" {
  target_group_arn = aws_lb_target_group.public-tg.arn
  target_id        = aws_instance.public_1b_ec2.id
}

# Create security group for LB:
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "open port 80 and 443 for www"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all of them
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# create ALB:
resource "aws_lb" "alb" {
  name                       = "public-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-sg.id]
  subnets                    = [aws_subnet.public-1a.id, aws_subnet.public-1b.id]
  enable_deletion_protection = false

  tags = {
    Name = "public-alb"
  }
}

# create alb listeners:
resource "aws_lb_listener" "http_listenter" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [
    aws_lb_listener.https_listener
  ]
}

# data call for ssl certificate:
data "aws_acm_certificate" "my_certificate" {
  domain   = "web.faceartchicago.net"
  statuses = ["ISSUED"]
}

# adding port443 listener to alb:
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.my_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public-tg.arn
  }
  depends_on = [
    aws_lb.alb
  ]
}

# Loockup route53 hosted zones :
data "aws_route53_zone" "hosted_zone" {
  name         = "faceartchicago.net"
  private_zone = false
}

# create route53 cname record to map to alb dns name:
resource "aws_route53_record" "my_cname_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "web.faceartchicago.net" # what to type in browser
  type    = "CNAME"
  ttl     = "100"
  records = [aws_lb.alb.dns_name] # what dns will return for dns query
}

# Create security group for RDS:
resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "allow 3306 from ec2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "allow 3306"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all of them
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Create db subnet group :
resource "aws_db_subnet_group" "subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private-1a.id, aws_subnet.private-1b.id]

  tags = {
    Name = "db_subnet_group"
  }
}

# Loockup my secret  in SSM :
data "aws_secretsmanager_secret_version" "credentials" {
  secret_id = "rds_credentials"
}

locals {
  rds_credentials = jsondecode(
  data.aws_secretsmanager_secret_version.credentials.secret_string)
}

# create db :
resource "aws_db_instance" "db" {
  allocated_storage           = 20
  db_name                     = "thirdlessondb"
  engine                      = "mysql"
  engine_version              = "5.7.37"
  instance_class              = "db.t3.micro"
  username                    = local.rds_credentials.username
  password                    = local.rds_credentials.password
  vpc_security_group_ids      = [aws_security_group.rds-sg.id]
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  multi_az                    = false
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  skip_final_snapshot         = true
}