variable "aws_profiles" {
    default = "default"  
}

variable "aws_region" {
  default = "ap-southeast-3"
}

variable "ami_id" {
  default = "ami-05212caffa4a257da"
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

variable "launch_template_name" {
  default = "dpay-lt"
}


variable "instance_type" {
  type = string
  default = "t3.medium"
}

variable "key_name" {
  type = string
  description = "default keypair set in aws console"
  default = "<existing aws key>"
}

variable "admin_users" {
  type = string
  description = "custom 2nd administrator"
  default = "<expected 2nd admin>"
}

variable "public_ssh_key" {
  type = string
  description = "custom 2dn administrator public ssh key"
  default = "<public key content here>"
}