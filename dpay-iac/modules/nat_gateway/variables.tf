variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID where NAT Gateway will be created"
}

variable "private_route_table_id" {
  type        = string
  description = "Route table ID of private subnet to route internet traffic"
}
