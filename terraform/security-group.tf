resource "aws_security_group" "web_server_security_group" {
    name = "${var.project}-web-server-security-group"
    description = "Security group for the web server"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "ssh_security_group" {
    name = "${var.project}-ssh-security-group"
    description = "Security group for the ssh"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "backend_server_security_group" {
    name = "${var.project}-backend-server-security-group"
    description = "Security group for the backend server"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.web_server_security_group.id]
    }
    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        security_groups = [aws_security_group.web_server_security_group.id]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "database_security_group" {
    name = "${var.project}-database-security-group"
    description = "Security group for the database"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.backend_server_security_group.id]
    }
}