module "networking" {
  source = "../../modules/networking"

  name_prefix            = "shorturl-dev"
  vpc_cidr               = var.vpc_cidr
  aws_availability_zones = var.availability_zones
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


module "security" {
  source = "../../modules/security"

  vpc_id      = module.networking.vpc_id
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region
  name_prefix = "shorturl-dev"

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}

module "endpoints" {
  source = "../../modules/endpoints"

  name_prefix            = "shorturl-dev"
  aws_region             = var.aws_region
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  private_route_table_id = module.networking.private_route_table_id
  security_group_id      = module.security.vpce_security_group_id

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


module "database" {
  source = "../../modules/database"

  name_prefix        = "shorturl-dev"
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.security.rds_security_group_id

  db_name     = "shorturl"
  db_username = "shorturl_admin"

  deletion_protection = var.rds_deletion_protection
  skip_final_snapshot = var.rds_skip_final_snapshot

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}

module "redis" {
  source = "../../modules/redis"

  name_prefix        = "shorturl-dev"
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.security.redis_security_group_id

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}

module "messaging" {
  source = "../../modules/messaging"

  name_prefix = "shorturl-dev"

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


module "ecr" {
  source = "../../modules/ecr"

  name_prefix = "shorturl-dev"

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


module "acm" {
  source = "../../modules/acm"

  domain_name        = var.certificate_domain_name
  cloudflare_zone_id = var.cloudflare_zone_id

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


module "load_balancing" {
  source = "../../modules/load-balancing"

  name_prefix = "shorturl-dev"

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}

module "waf" {
  source = "../../modules/waf"

  name_prefix = "shorturl-dev"
  alb_arn     = module.load_balancing.alb_arn

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}

module "dns" {
  source = "../../modules/dns"

  domain_name        = var.certificate_domain_name
  cloudflare_zone_id = var.cloudflare_zone_id
  alb_dns_name       = module.load_balancing.alb_dns_name
}


module "iam" {
  source = "../../modules/iam"

  name_prefix = "shorturl-dev"

  click_events_queue_arn = module.messaging.queue_arn
  database_secret_arn    = module.database.master_user_secret_arn

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


module "ecs_platform" {
  source = "../../modules/ecs-platform"

  name_prefix = "shorturl-dev"
  aws_region  = var.aws_region

  repository_urls = module.ecr.repository_urls
  image_tag       = "bootstrap-amd64"

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn

  api_task_role_arn       = module.iam.api_task_role_arn
  worker_task_role_arn    = module.iam.worker_task_role_arn
  dashboard_task_role_arn = module.iam.dashboard_task_role_arn

  database_host       = module.database.address
  database_port       = module.database.port
  database_name       = module.database.database_name
  database_secret_arn = module.database.master_user_secret_arn

  redis_host = module.redis.primary_endpoint_address
  redis_port = module.redis.port

  sqs_queue_url = module.messaging.queue_url

  log_group_names = module.observability.log_group_names

  private_subnet_ids = module.networking.private_subnet_ids

  api_security_group_id       = module.security.api_security_group_id
  worker_security_group_id    = module.security.worker_security_group_id
  dashboard_security_group_id = module.security.dashboard_security_group_id

  api_target_group_arn       = module.load_balancing.target_group_arns["api"]
  dashboard_target_group_arn = module.load_balancing.target_group_arns["dashboard"]

  api_desired_count       = 2
  worker_desired_count    = 1
  dashboard_desired_count = 2

  sqs_queue_name = module.messaging.queue_name

  api_min_capacity = 2
  api_max_capacity = 4

  worker_min_capacity = 1
  worker_max_capacity = 5

  worker_backlog_target = 10

  dashboard_min_capacity = 2
  dashboard_max_capacity = 4

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}

module "observability" {
  source = "../../modules/observability"

  name_prefix       = "shorturl-dev"
  retention_in_days = 30
  alert_email       = var.alert_email

  alb_arn_suffix            = module.load_balancing.alb_arn_suffix
  target_group_arn_suffixes = module.load_balancing.target_group_arn_suffixes

  ecs_cluster_name = module.ecs_platform.cluster_name

  ecs_service_names = {
    api       = module.ecs_platform.api_service_name
    worker    = module.ecs_platform.worker_service_name
    dashboard = module.ecs_platform.dashboard_service_name
  }

  tags = {
    Project     = "event-driven-url-shortener"
    Environment = "dev"
  }
}


