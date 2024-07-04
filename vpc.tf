# Description: This file is used to create a VPC in AWS

# Define the VPC
resource "aws_vpc" "three_tier_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "three_tier_vpc"
    }
}

# Define the public subnet in AZ 1a
resource "aws_subnet" "Public-Web-Subnet-AZ-1a" {
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.0.0.0/24"
    
    availability_zone = "us-east-1a"

    tags = {
        Name = "Public-Web-Subnet-AZ-1a"
    }
}

# Define the private subnet in AZ 1a
resource "aws_subnet" "Private-App-Subnet-AZ-1a" {
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.0.1.0/24"

    availability_zone = "us-east-1a"

    tags = {
        Name = "Private-App-Subnet-AZ-1a"
    }

}

# Define the private subnet in AZ 1a
resource "aws_subnet" "Private-DB-Subnet-AZ-1a" {
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.0.2.0/24"

    availability_zone = "us-east-1a"

    tags = {
        Name = "Private-DB-Subnet-AZ-1a"
    }
}

# Define the public subnet in AZ 1b
resource "aws_subnet" "Public-Web-Subnet-AZ-1b" {
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.0.3.0/24"

    availability_zone = "us-east-1b"

    tags = {
        Name = "Public-Web-Subnet-AZ-1b"
    }
}

# Define the private subnet in AZ 1b
resource "aws_subnet" "Private-App-Subnet-AZ-1b" {
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.0.4.0/24"

    availability_zone = "us-east-1b"

    tags = {
        Name = "Private-App-Subnet-AZ-1b"
    }
}

# Define the private subnet in AZ 1b
resource "aws_subnet" "Private-DB-Subnet-AZ-1b" {
    vpc_id = aws_vpc.three_tier_vpc.id
    cidr_block = "10.0.5.0/24"

    availability_zone = "us-east-1b"

    tags = {
        Name = "Private-DB-Subnet-AZ-1b"
    }
}


# Define the internet gateway
resource "aws_internet_gateway" "three_tier_igw" {
    vpc_id = aws_vpc.three_tier_vpc.id

    tags = {
        Name = "three_tier_igw"
    }
}

# Create EIP for NAT Gateway in AZ 1a
resource "aws_eip" "nat_eip_az_1a" {
    domain = "vpc"

    tags = {
        Name = "nat_eip_az_1a"
    }
}

# Define NAT Gateway in AZ 1a
resource "aws_nat_gateway" "nat_gateway_az_1a" {
    allocation_id = aws_eip.nat_eip_az_1a.id
    subnet_id = aws_subnet.Public-Web-Subnet-AZ-1a.id
    connectivity_type = "public"

    tags = {
        Name = "nat_gateway_az_1a"
    }

    depends_on = [ aws_internet_gateway.three_tier_igw ]
}

# Create EIP for NAT Gateway in AZ 1b
resource "aws_eip" "nat_eip_az_1b" {
    domain = "vpc"

    tags = {
        Name = "nat_eip_az_1b"
    }
}

# Define NAT Gateway in AZ 1b
resource "aws_nat_gateway" "nat_gateway_az_1b" {
    allocation_id = aws_eip.nat_eip_az_1b.id
    subnet_id = aws_subnet.Public-Web-Subnet-AZ-1b.id
    connectivity_type = "public"

    tags = {
        Name = "nat_gateway_az_1b"
    }

    depends_on = [ aws_internet_gateway.three_tier_igw ]
}


# Define the route table for public subnet in AZ
resource "aws_route_table" "PublicRouteTable" {
    vpc_id = aws_vpc.three_tier_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.three_tier_igw.id
    }

    tags = {
        Name = "PublicRouteTable"
    }
}


resource "aws_route_table_association" "PublicRouteTableAssociationAZ1a" {
    subnet_id = aws_subnet.Public-Web-Subnet-AZ-1a.id
    route_table_id = aws_route_table.PublicRouteTable.id
  
}

resource "aws_route_table_association" "PublicRouteTableAssociationAZ1b" {
    subnet_id = aws_subnet.Public-Web-Subnet-AZ-1b.id
    route_table_id = aws_route_table.PublicRouteTable.id
  
}

# Define the route table for private subnet in AZ 1a
resource "aws_route_table" "PrivateRouteTableAZ1a" {
    vpc_id = aws_vpc.three_tier_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway_az_1a.id
    }

    tags = {
        Name = "PrivateRouteTableAZ1a"
    }
}

resource "aws_route_table_association" "PrivateRouteTableAssociationAZ1a" {
    subnet_id = aws_subnet.Private-App-Subnet-AZ-1a.id
    route_table_id = aws_route_table.PrivateRouteTableAZ1a.id
  
}

resource "aws_route_table" "PrivateRouteTableAZ1b" {
    vpc_id = aws_vpc.three_tier_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway_az_1b.id
    }

    tags = {
        Name = "PrivateRouteTableAZ1b"
    }  
}

resource "aws_route_table_association" "PrivateRouteTableAssociationAZ1b" {
    subnet_id = aws_subnet.Private-App-Subnet-AZ-1b.id
    route_table_id = aws_route_table.PrivateRouteTableAZ1b.id
  
}

####################
## Security Group ##
####################

resource "aws_security_group" "internet_facing_loadbalacer_sg" {
    vpc_id = aws_vpc.three_tier_vpc.id
    name = "internet_facing_loadbalacer_sg"
    description = "Allow HTTP and HTTPS inbound traffic"
  
    tags = {
      Name = "internet_facing_loadbalacer_sg"
    }
}

# Inbound
resource "aws_vpc_security_group_ingress_rule" "http_myip" {
    security_group_id = aws_security_group.internet_facing_loadbalacer_sg.id 
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr_ipv4 = "${local.my_ip}/32"
  }

# Outbound
resource "aws_vpc_security_group_egress_rule" "http_egress" {
    security_group_id = aws_security_group.internet_facing_loadbalacer_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"   
}

# Securtiy Group for Web Tier 
resource "aws_security_group" "web_tier_sg" {
    vpc_id = aws_vpc.three_tier_vpc.id
    name = "web_tier_sg"
    description = "Security group for web tier instances"
  
    tags = {
      Name = "web_tier_sg"
    }
}

# Inbound
resource "aws_vpc_security_group_ingress_rule" "web_tier_sg_ingress_myip" {
    security_group_id = aws_security_group.web_tier_sg.id
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr_ipv4 = "${local.my_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "web_tier_sg_ingress_internet_lb" {
    security_group_id = aws_security_group.web_tier_sg.id
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.internet_facing_loadbalacer_sg.id
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "web_tier_sg_egress" {
    security_group_id = aws_security_group.web_tier_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}

# Security Group for Internal Load Balancer
resource "aws_security_group" "internal_loadbalacer_sg" {
    vpc_id = aws_vpc.three_tier_vpc.id
    name = "internal_loadbalacer_sg"
    description = "Security group for internal load balancer"
  
    tags = {
      Name = "internal_loadbalacer_sg"
    }
}

# Inbound
resource "aws_vpc_security_group_ingress_rule" "internal_loadbalacer_sg_ingress" {
    security_group_id = aws_security_group.internal_loadbalacer_sg.id
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.web_tier_sg.id
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "internal_loadbalacer_sg_egress" {
    security_group_id = aws_security_group.internal_loadbalacer_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}


# Security Group for App Tier
resource "aws_security_group" "private_instance_sg" {
    vpc_id = aws_vpc.three_tier_vpc.id
    name = "private_instance_sg"
    description = "Security group for private instances"
  
    tags = {
      Name = "private_instance_sg"
    }
}

# Inbound
resource "aws_vpc_security_group_ingress_rule" "private_instance_sg_ingress_myip" {
    security_group_id = aws_security_group.private_instance_sg.id
    from_port = 4000
    to_port = 4000
    ip_protocol = "tcp"
    cidr_ipv4 = "${local.my_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "private_instance_sg_ingress_internal_lb" {
    security_group_id = aws_security_group.private_instance_sg.id
    from_port = 4000
    to_port = 4000
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.internal_loadbalacer_sg.id
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "private_instance_sg_egress" {
    security_group_id = aws_security_group.private_instance_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}


# Security Group for DB Tier
resource "aws_security_group" "db_tier_sg" {
    vpc_id = aws_vpc.three_tier_vpc.id
    name = "db_tier_sg"
    description = "Security group for db tier instances"
  
    tags = {
      Name = "db_tier_sg"
    }
}

# Inbound
resource "aws_vpc_security_group_ingress_rule" "db_tier_sg_ingress_private_instance_sg" {
    security_group_id = aws_security_group.db_tier_sg.id
    from_port = 3306
    to_port = 3306
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.private_instance_sg.id
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "db_tier_sg_egress" {
    security_group_id = aws_security_group.db_tier_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}

