module "vpc" {
  source = "./modules/vpc"
  name   = "incident-logger"
}

module "rds" {
  source      = "./modules/rds"
  name        = "incident-logger"
  db_username = "appuser"

  subnet_ids = [
    module.vpc.private_a_subnet_id,
    module.vpc.private_b_subnet_id
  ]

  vpc_id = module.vpc.vpc_id
}
