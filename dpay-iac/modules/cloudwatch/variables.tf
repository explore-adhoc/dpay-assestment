variable "asg_name" {
  type        = string
  description = "Name of the Auto Scaling Group"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for alarm names"
  default     = "asg-monitor"
}
