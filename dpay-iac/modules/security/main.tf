resource "aws_security_group" "asg_sg" {
  name        = "${var.name_prefix}-asg-sg"
  description = "Security group for ASG EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-asg-sg"
  }
}
