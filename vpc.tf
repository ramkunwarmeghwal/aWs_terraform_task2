provider "aws" {
  region     = "ap-south-1"
  profile   = "myvimal"
}


resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a" 
  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main"
   }
}



resource "aws_route_table" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.main.id}"
     
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}


resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = "${aws_subnet.main.id}"
    route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}


/*private subnet*/

resource "aws_subnet" "main12" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "main12"
   }
}




variable "enter_ur_key_name" {
          type = string
          default = "mykey1111"
}

/*instances 1*/

resource "aws_instance"  "myin" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name      =  var.enter_ur_key_name
  vpc_security_group_ids  =  ["${aws_security_group.My_VPC_Security_Group.id}"] 
  subnet_id       =     "${aws_subnet.main.id}"
  associate_public_ip_address = true
  availability_zone = "ap-south-1a"
  tags = {
    Name = "coronaWorld"
  }
  depends_on = [aws_security_group.My_VPC_Security_Group ,]
} 


/*instance 2*/

resource "aws_instance"  "mysql" {
  ami           = "ami-07a8c73a650069cf3"
  instance_type = "t2.micro"
  key_name      =  var.enter_ur_key_name
  vpc_security_group_ids  =  ["${aws_security_group.My_VPC_Security_Group.id}"] 
  subnet_id       =     "${aws_subnet.main12.id}"
  associate_public_ip_address = false
  availability_zone = "ap-south-1b"
  tags = {
    Name = "coronaWorld"
  }
  depends_on = [aws_security_group.My_VPC_Security_Group ,]
} 


/*security groups for both instances*/

# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group" {
  vpc_id       = aws_vpc.main.id
  name         = "My VPC Security Group"
  description  = "My VPC Security Group"
  
  # allow ingress of port 22
  ingress {
      
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "My VPC Security Group"
   Description = "My VPC Security Group"
}
 depends_on = [aws_vpc.main,]
} # end resource