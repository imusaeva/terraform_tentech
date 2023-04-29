module "vpc" {
  source     = "./vpc"
  cidr_block = "10.0.0.0/16"
  vpc_tag    = "module_vpc"
}

# create public subnets :
module "public_subnets" {
  source                  = "./subnets"
  subnet_cidr_blocks      = ["10.0.0.0/18", "10.0.64.0/18"]
  map_public_ip_on_launch = true
  vpc_id                  = module.vpc.vpc_id
}

# create private subnets:
module "private_subnets" {
  source                  = "./subnets"
  subnet_cidr_blocks      = ["10.0.128.0/18", "10.0.192.0/18"]
  map_public_ip_on_launch = false
  vpc_id                  = module.vpc.vpc_id
}