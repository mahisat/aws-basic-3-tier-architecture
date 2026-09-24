resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
    key_name = "${var.project}-deployer-key"
    public_key = tls_private_key.main.public_key_openssh
}

resource "local_file" "main_private_key" {
    content = tls_private_key.main.private_key_pem
    filename = "${var.project}-deployer-key.pem"
    file_permission = "0600"
}
resource "aws_instance" "web_server" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    key_name = aws_key_pair.main.key_name
  user_data = base64encode(templatefile("${path.module}/frontend-setup.sh", {
    github_repo = var.github_repo_url
  }))
      security_groups = [aws_security_group.web_server_security_group.id,aws_security_group.ssh_security_group.id]
    tags = {
        Name = "${var.project}-web-server"
    }
}

resource "aws_instance" "backend_server" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private_subnet.id
    key_name = aws_key_pair.main.key_name
    user_data = base64encode(templatefile("${path.module}/backend-setup.sh", {
    github_repo       = var.github_repo_url
    db_endpoint       = aws_db_instance.rds.endpoint
    db_name           = var.db_name
    db_user           = var.db_username
    db_password       = var.db_password
  }))
    security_groups = [aws_security_group.backend_server_security_group.id,aws_security_group.ssh_security_group.id]
    tags = {
        Name = "${var.project}-backend-server"
    }
}