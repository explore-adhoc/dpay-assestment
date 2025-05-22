variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for private subnet"
}

variable "az" {
  type        = string
  description = "Availability zone"
}
