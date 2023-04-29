# create vpc:
module "staging_vpc" {
  source                      = "github.com/russgazin/terraform_vpc_module"
  vpc_cidr_block              = "10.0.2.0/24"
  public_subnets_cidr_blocks  = ["10.0.2.0/26", "10.0.2.64/26"]
  private_subnets_cidr_blocks = ["10.0.2.128/26", "10.0.2.192/26"]
}