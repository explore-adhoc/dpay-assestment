variable "private_subnet_id" {
  type        = string
  description = "Private subnet for ASG"
}

variable "launch_template_name" {
  type        = string
  default     = "asg-template"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use in launch template"
}

variable "instance_type" {
  type = string
  default = "t2.medium"
}

variable "key_name" {
  type = string
  description = "default keypair set in aws console"
}

variable "admin_users" {
  type = string
  description = "custom 2nd administrator"
}

variable "public_ssh_key" {
  type = string
  description = "custom 2dn administrator public ssh key"
}

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  # default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  # default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  # default     = 2
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the launch template"
}
