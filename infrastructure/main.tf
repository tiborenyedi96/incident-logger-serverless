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

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  name   = "incident-logger"
  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_a_subnet_id,
    module.vpc.private_b_subnet_id
  ]
  aws_region = "eu-central-1"
}


//SG rules
resource "aws_security_group_rule" "rds_proxy_ingress_from_lambda" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds_proxy.rds_proxy_security_group_id
  source_security_group_id = module.lambda.lambda_security_group_id
}

resource "aws_security_group_rule" "rds_ingress_from_rds_proxy" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds.rds_sg_id
  source_security_group_id = module.rds_proxy.rds_proxy_security_group_id
}

resource "aws_security_group_rule" "lambda_egress_to_rds_proxy" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.lambda.lambda_security_group_id
  source_security_group_id = module.rds_proxy.rds_proxy_security_group_id
}

resource "aws_security_group_rule" "lambda_egress_to_vpce" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.lambda.lambda_security_group_id
  source_security_group_id = module.vpc_endpoints.vpce_security_group_id
}

resource "aws_security_group_rule" "vpce_ingress_from_lambda" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.vpc_endpoints.vpce_security_group_id
  source_security_group_id = module.lambda.lambda_security_group_id
}

resource "aws_security_group_rule" "rds_proxy_egress_to_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds_proxy.rds_proxy_security_group_id
  source_security_group_id = module.rds.rds_sg_id
}