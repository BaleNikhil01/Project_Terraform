resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id

}

resource "aws_route_table" "RT" {                  # Creates a new route table named RT
    vpc_id = aws_vpc.my_vpc.id
    route {
        # everything leaving the VPC/subnets points to the internet gateway
        cidr_block = "0.0.0.0/0"                                 # destination 
        gateway_id = aws_internet_gateway.igw.id                 # target 
    }
} 

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.RT.id
}    

resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow ssh and http-inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "web_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "<your_public_ip>/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_outflow" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "instance1" {
  ami = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data_base64 = base64encode(file("userdata.sh"))
}

resource "aws_instance" "instance2" {
  ami = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data_base64 = base64encode(file("userdata1.sh"))
}

terraform {
  backend "s3" {
    bucket       = "project-terraform-123"
    key          = "demo/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
