variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming the security group"
  type        = string
  default     = "dpay-sg"
}

variable "my_ip_cidr" {
  description = "CIDR block of your trusted IP for SSH access"
  type        = string
}
