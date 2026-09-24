resource "aws_db_subnet_group" "database_subnet_group" {
  name = "${var.project}-database-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_2.id,
  ]

  tags = {
    Name = "${var.project}-database-subnet-group"
  }
}

resource "aws_db_instance" "database" {
  identifier              = "${var.project}-mysql"
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_security_group.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = {
    Name = "${var.project}-database"
  }
}
