
#-------------------
# Security Groups:
#------------------

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Controls network access for the public Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "api" {
  name        = "${var.name_prefix}-api-sg"
  description = "Controls network access to the API ECS tasks"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-api-sg"
  })
}

resource "aws_security_group" "worker" {
  name        = "${var.name_prefix}-worker-sg"
  description = "Controls network access for the background Worker tasks"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-worker-sg"
  })
}


resource "aws_security_group" "dashboard" {
  name        = "${var.name_prefix}-dashboard-sg"
  description = "Controls network access to Dashboard ECS tasks"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-dashboard-sg"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allows PostgreSQL connections only from services that need the database"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}


resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Allows Redis connections only from the API tasks"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-redis-sg"
  })
}

resource "aws_security_group" "vpce" {
  name        = "${var.name_prefix}-vpce-sg"
  description = "Allows private (HTTPS) ECS traffic into our interface VPC endpoints"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpce-sg"
  })
}


#========
# Public ingress : Internet ---> ALB
#========

resource "aws_vpc_security_group_ingress_rule" "internet_to_alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP from the internet into ALB"
}


resource "aws_vpc_security_group_ingress_rule" "internet_to_alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS from the internet to the ALB"
}


## ALB --> APP


resource "aws_vpc_security_group_ingress_rule" "alb_to_api_ingress" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "Allow ALB traffic into API tasks on port 8080"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_api_egress" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "Allow ALB outbound traffic to API tasks on port 8080"
}



resource "aws_vpc_security_group_ingress_rule" "alb_to_dashboard_ingress" {
  security_group_id            = aws_security_group.dashboard.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8081
  to_port                      = 8081
  ip_protocol                  = "tcp"
  description                  = "Allows the ALB to forward Dashboard requests to Dashboard tasks on port 8081"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_dashboard_egress" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.dashboard.id
  from_port                    = 8081
  to_port                      = 8081
  ip_protocol                  = "tcp"
  description                  = "Allow ALB outbound traffic to Dashboard tasks on port 8081"
}


# PostgreSQL Access 
# API/ WORKER/ Dashboard --> RDS


resource "aws_vpc_security_group_ingress_rule" "api_to_rds_ingress" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow API tasks to connect to PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "api_to_rds_egress" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow API outbound PostgreSQL traffic to RDS"
}


resource "aws_vpc_security_group_ingress_rule" "worker_to_rds_ingress" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allows the analytics Worker to write click data into PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "worker_to_rds_egress" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow Worker outbound PostgreSQL traffic to RDS"
}


resource "aws_vpc_security_group_ingress_rule" "dashboard_to_rds_ingress" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.dashboard.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allows the Dashboard to read analytics from PostgreSQL"
}



resource "aws_vpc_security_group_egress_rule" "dashboard_rds_egress" {
  security_group_id            = aws_security_group.dashboard.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow Dashboard outbound PostgreSQL traffic to RDS"
}

# API --> REDIS (Cache Access)

resource "aws_vpc_security_group_ingress_rule" "api_redis_ingress" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  description                  = "Allows only the API to connect to Redis on port 6379 for URL caching"
}

resource "aws_vpc_security_group_egress_rule" "api_redis_egress" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.redis.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  description                  = "Allow API outbound Redis traffic to ElasticCache - for caching"
}




## Private AWS Service Access (VPC Endpoints)

resource "aws_vpc_security_group_ingress_rule" "api_to_vpce_ingress" {
  security_group_id            = aws_security_group.vpce.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = " Allow HTTPS from API tasks to interface VPC endpoints "
}


resource "aws_vpc_security_group_egress_rule" "api_to_vpce_egress" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.vpce.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "API reaches AWS services privately through interface endpoints"
}

resource "aws_vpc_security_group_ingress_rule" "worker_to_vpce_ingress" {
  security_group_id            = aws_security_group.vpce.id
  referenced_security_group_id = aws_security_group.worker.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "HTTPS from Worker tasks to interface VPC endpoints"
}

resource "aws_vpc_security_group_egress_rule" "worker_to_vpce_egress" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.vpce.id
  to_port                      = 443
  from_port                    = 443
  ip_protocol                  = "tcp"
  description                  = "Worker reaches AWS services such as SQS privately"
}


resource "aws_vpc_security_group_ingress_rule" "dashboard_to_vpce_ingress" {
  security_group_id            = aws_security_group.vpce.id
  referenced_security_group_id = aws_security_group.dashboard.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "HTTPS from Dashboard tasks to interface VPC endpoints"
}

resource "aws_vpc_security_group_egress_rule" "dashboard_to_vpce_egress" {
  security_group_id            = aws_security_group.dashboard.id
  referenced_security_group_id = aws_security_group.vpce.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Dashboard can reach required AWS services privately"
}

# ==================================================
# S3 Gateway Endpoint Access
# Required for private ECR image layer pulls
# ==================================================

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_security_group_egress_rule" "api_to_s3_egress" {
  security_group_id = aws_security_group.api.id
  prefix_list_id    = data.aws_prefix_list.s3.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow API tasks HTTPS access to S3 through the S3 gateway endpoint"
}

resource "aws_vpc_security_group_egress_rule" "worker_to_s3_egress" {
  security_group_id = aws_security_group.worker.id
  prefix_list_id    = data.aws_prefix_list.s3.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow Worker tasks HTTPS access to S3 through the S3 gateway endpoint"
}

resource "aws_vpc_security_group_egress_rule" "dashboard_to_s3_egress" {
  security_group_id = aws_security_group.dashboard.id
  prefix_list_id    = data.aws_prefix_list.s3.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow Dashboard tasks HTTPS access to S3 through the S3 gateway endpoint"
}







#security_group_id = ... "Where is the traffic going?"/ "
# e.g: security_group_id = aws_security_group.api.id = Traffic is being allowed INTO the API SG

# referenced_security_group_id = ...Where is the traffic coming from?
# security_group_id            = aws_security_group.api.id
# referenced_security_group_id = aws_security_group.alb.id
# = ALB SG (SOURCE) ---> API SG (DESTINATION)

# SG ID = DESTINATION 
# RSG ID = SOURCE 


