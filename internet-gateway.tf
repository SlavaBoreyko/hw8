resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc_eks.id

  tags = {
    Name = "yboreyko"
  }
}