resource "aws_db_subnet_group" "database_subnet_group" {
    name = "${var.project}-database-subnet-group"
    subnet_ids = [aws_subnet.private_subnet.id]
    tags = {
        Name = "${var.project}-database-subnet-group"
    }
}

resource "aws_db_instance" "database" {
    allocated_storage = 10
    engine = "mysql"
    engine_version = "8.0.32"
    instance_class = "db.t2.micro"
    db_name = "${var.project}-database"
    username = "admin"
    password = "admin123"
    port = 3306
    db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
    tags = {
        Name = "${var.project}-database"
    }
    skip_final_snapshot = true

}