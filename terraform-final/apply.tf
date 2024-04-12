module "infrastructure_module" {
  source = "./modules/infrastructure_module"
  private_subnets = var.my_private_subnets
  public_subnets = var.my_public_subnets
}

module "ec2_module" {
  source = "./modules/ec2_module"
  #you can customize any attribute value below
  vpc-id = module.infrastructure_module.vpc_id
  public_subnets_ids = module.infrastructure_module.public-subnets-id
  private_subnets_ids = module.infrastructure_module.private-subnets-id
}


module "elb_module" {
  source = "./modules/elb_module"
  proxy-server-id = module.ec2_module.proxy-id
  apache-server-id = module.ec2_module.apache-id
  proxy-lb-subnets = module.infrastructure_module.public-subnets-id
  vpc_id = module.infrastructure_module.vpc_id
  apache-lb-subnets = module.infrastructure_module.private-subnets-id
}

output "internet-loadbalancer" {
  value = module.elb_module.internet-lb
}

output "internal-loadbalancer" {
  value = module.elb_module.internal-lb
}