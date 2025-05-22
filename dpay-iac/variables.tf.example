# provider "aws" {
#     shared_credentials_files = [ "./aws/credentials" ]
#     profile = var.aws_profiles
#     region = var.aws_region
# }

variable "aws_profiles" {
    default = "default"  
}

variable "aws_region" {
  default = "ap-southeast-3"
}

variable "aws_bucket" {
  default = "playground-bucket"
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "bucket_name" {
    default = "terraform-state"
}

variable "ami_id" {
    default = "ami-026c39f4021df9abe"
  
}

variable "launch_template_name" {
  default = "dpay-lt"
}


variable "instance_type" {
  type = string
  default = "t2.medium"
}

variable "key_name" {
  type = string
  description = "default keypair set in aws console"
  default = "privates"
}

variable "admin_users" {
  type = string
  description = "custom 2nd administrator"
  default = "sayadmins"
}

variable "public_ssh_key" {
  type = string
  description = "custom 2dn administrator public ssh key"
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJzdDv3w4qVHugRm/C/+PVH75iN8AYpgtjvrcBOYpGB9 sayadmins"
}

# variable "asg_min_size" {
#   description = "Minimum number of instances in the Auto Scaling Group"
#   type        = number
#   default     = 2
# }

# variable "asg_max_size" {
#   description = "Maximum number of instances in the Auto Scaling Group"
#   type        = number
#   # default     = 5
# }

# variable "asg_desired_capacity" {
#   description = "Desired number of instances in the Auto Scaling Group"
#   type        = number
#   # default     = 2
# }

# variable "security_group_id" {
#   type        = string
#   description = "Security group ID for the launch template"
# }
