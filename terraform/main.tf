data "aws_availability_zones" "available" {
    state = "available"
}

locals {
    azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
    vpc_cidr = "10.17.0.0/16"
    vpc_name = "simple-social-vpc"
    db_username = "admin"
    db_name     = "simplesocialdb"
    db_allocated_storage = 8
    db_instance_class    = "db.t3.micro"
    db_engine            = "mysql"
    db_engine_version    = "8.0"
    db_identifier       = "simple-social-db"
    cluster_name       = "simple-social-eks"


}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "6.5.1"
    name = local.vpc_name
    cidr = local.vpc_cidr
    azs = local.azs
    create_database_nat_gateway_route = true
    create_private_nat_gateway_route = true
    database_subnet_group_name = "${local.vpc_name}-db-subnet-group"
    database_subnet_names = ["${local.vpc_name}-db-subnet-1", "${local.vpc_name}-db-subnet-2", "${local.vpc_name}-db-subnet-3"]
    private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
    public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
    database_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]


    create_database_subnet_group = true
    enable_nat_gateway = true
    single_nat_gateway = false
    one_nat_gateway_per_az = true
    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
    
    

}

module "mysql_rds_sg" {
    source = "terraform-aws-modules/security-group/aws"
    version = "4.14.0"
    name = "mysql-rds-sg"
    vpc_id = module.vpc.vpc_id
    ingress_with_cidr_blocks = [
        {
            from_port   = 3306
            to_port     = 3306
            protocol    = "tcp"
            cidr_blocks = module.vpc.vpc_cidr_block
            description = "Allow MySQL access from within VPC"
        }
    ]
  
}

resource "random_password" "db_password" {
    length  = 16
    special = true
    override_special = "_%@"
  
}

resource "aws_ssm_parameter" "db_password_parameter" {
    name  = "/simple-social/db_password"
    type  = "SecureString"
    value = random_password.db_password.result
    description = "The password for the RDS database"
  
}





module "mysql_rds" {
    source = "terraform-aws-modules/rds/aws"
    version = "6.13.1"
    identifier = local.db_identifier
    engine = local.db_engine
    engine_version = local.db_engine_version
    family = "${local.db_engine}${local.db_engine_version}"
    major_engine_version = local.db_engine_version
    instance_class = local.db_instance_class
    allocated_storage = local.db_allocated_storage
    db_name = local.db_name
    username = local.db_username
    password = random_password.db_password.result
    manage_master_user_password = false
    vpc_security_group_ids = [module.mysql_rds_sg.security_group_id]
    db_subnet_group_name = module.vpc.database_subnet_group_name
    multi_az = false
    publicly_accessible = false
    skip_final_snapshot = true
    deletion_protection = false
    performance_insights_enabled = false
    performance_insights_retention_period = 7
    monitoring_interval = 60
    create_monitoring_role = true
    parameters = [
    {
        name  = "slow_query_log"
        value = "1"
    },

    {
        name  = "long_query_time"
        value = "2"
    },

     {
        name  = "log_output"
        value = "FILE"
    },

     {
        name = "time_zone"
        value = "UTC"
    }]

    tags = {
        Name = "simple-social-mysql-rds"
    }
    
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"
    name = local.cluster_name
    kubernetes_version = "1.34"
    endpoint_private_access = true
    endpoint_public_access = true
    enable_cluster_creator_admin_permissions = true
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
    compute_config = {
        enabled = true
        node_pools = ["general-purpose"]
    }
    tags = {
        Name = "simple-social-eks-cluster"

    }

  
}


