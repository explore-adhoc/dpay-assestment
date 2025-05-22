provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.2.0/24"
  az                   = "ap-southeast-3a"
}


module "security_group" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  name_prefix = "asg"
  my_ip_cidr  = "<Change to your IP>"
}

module "nat_gateway" {
  source                = "./modules/nat_gateway"
  public_subnet_id      = module.vpc.public_subnet_id
  private_route_table_id = module.vpc.private_route_table_id 
}

module "autoscaling" {
  source            = "./modules/ec2-autoscaling"
  private_subnet_id  = module.vpc.private_subnet_id
  launch_template_name = "asg-template"
  ami_id            =  var.ami_id
  instance_type     =  var.instance_type
  key_name          = var.key_name
  admin_users       = var.admin_users
  public_ssh_key    = var.public_ssh_key
  asg_min_size      = 2
  asg_max_size      = 5
  asg_desired_capacity = 2
  security_group_id = module.security_group.asg_sg_id


}

module "cloudwatch" {
  source     = "./modules/cloudwatch"
  asg_name   = module.autoscaling.asg_name
  name_prefix = "asg"
}
