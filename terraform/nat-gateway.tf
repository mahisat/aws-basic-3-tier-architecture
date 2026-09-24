resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "${var.project}-nat-gateway"
  }
  depends_on = [aws_internet_gateway.main]
}
