resource "aws_iam_role" "ec2_role" {
  name = "ec2-autoscaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach CloudWatch Agent Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Attach ReadOnly EC2 Policy to IAM Role
resource "aws_iam_role_policy_attachment" "basic_ec2_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-autoscaling-profile"
  role = aws_iam_role.ec2_role.name
}

# AMI Data Source — filter by ID passed in variable (ensure var.ami_id is correct and valid in your region)
data "aws_ami" "validated" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}

# Launch Template for EC2 instances in Auto Scaling Group
resource "aws_launch_template" "lt" {
  name_prefix   = var.launch_template_name
  image_id      = data.aws_ami.validated.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh.tpl", {
    username   = var.admin_users
    public_key = var.public_ssh_key
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "autoscaling-instance"
    }
  }

  monitoring {
    enabled = true
  }
}

# Auto Scaling Group using the launch template
resource "aws_autoscaling_group" "asg" {
  name                      = "asg-app"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = [var.private_subnet_id]
  health_check_type         = "EC2"
  health_check_grace_period = 180
  termination_policies      = ["OldestInstance"]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy — scales out based on average CPU utilization
resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "scale-out-on-high-cpu"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 45.0
  }
}
