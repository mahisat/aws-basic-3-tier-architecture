resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    tags = {
        Name = "${var.project}-public-subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr
    tags = {
        Name = "${var.project}-private-subnet"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.project}-internet-gateway"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    route {
        cidr_block ="10.0.0.0/16"
        gateway_id = "local"
    }
    tags = {
        Name = "${var.project}-public-route-table"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "10.0.0.0/16"
        local_gateway_id = "local"
    }
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }
    tags = {
        Name = "${var.project}-private-route-table"
         }
}

resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}   

