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

module "rds_proxy" {
  source          = "./modules/rds_proxy"
  name            = "incident-logger"
  vpc_id          = module.vpc.vpc_id
  rds_cluster_identifier = module.rds.rds_cluster_identifier

  subnet_ids = [
    module.vpc.private_a_subnet_id,
    module.vpc.private_b_subnet_id
  ]

  rds_cluster_arn               = module.rds.rds_cluster_arn
  rds_secretsmanager_secret_arn = module.rds.rds_secretsmanager_secret_arn
}