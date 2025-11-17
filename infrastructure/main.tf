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
  source                 = "./modules/rds_proxy"
  name                   = "incident-logger"
  vpc_id                 = module.vpc.vpc_id
  rds_cluster_identifier = module.rds.rds_cluster_identifier

  subnet_ids = [
    module.vpc.private_a_subnet_id,
    module.vpc.private_b_subnet_id
  ]

  rds_cluster_arn               = module.rds.rds_cluster_arn
  rds_secretsmanager_secret_arn = module.rds.rds_secretsmanager_secret_arn
}

module "lambda" {
  source = "./modules/lambda"
  name   = "incident-logger"
  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_a_subnet_id,
    module.vpc.private_b_subnet_id
  ]

  rds_secretsmanager_secret_arn = module.rds.rds_secretsmanager_secret_arn
  rds_proxy_endpoint            = module.rds_proxy.proxy_endpoint
}

//Security group rule definitions
resource "aws_security_group_rule" "allow_lambda_to_rds_proxy" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds_proxy.rds_proxy_security_group_id
  source_security_group_id = module.lambda.lambda_security_group_id
}

resource "aws_security_group_rule" "allow_rds_proxy_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds.rds_sg_id
  source_security_group_id = module.rds_proxy.rds_proxy_security_group_id
}