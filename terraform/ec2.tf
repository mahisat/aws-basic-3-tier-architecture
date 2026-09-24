resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project}-deployer-key"
  public_key = tls_private_key.main.public_key_openssh
}

resource "local_file" "main_private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${path.module}/${var.project}-deployer-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "backend_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.backend_server_security_group.id,
  ]

  user_data = base64encode(templatefile("${path.module}/backend-setup.sh", {
    github_repo = var.github_repo_url
    db_endpoint = aws_db_instance.database.address
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
  }))

  tags = {
    Name = "${var.project}-backend-server"
  }

  depends_on = [aws_db_instance.database]
}

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.web_server_security_group.id,
    aws_security_group.ssh_security_group.id,
  ]

  user_data = base64encode(templatefile("${path.module}/frontend-setup.sh", {
    github_repo  = var.github_repo_url
    backend_host = aws_instance.backend_server.private_ip
  }))

  tags = {
    Name = "${var.project}-web-server"
  }

  depends_on = [aws_instance.backend_server]
}
