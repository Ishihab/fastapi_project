module "vpc" {
    source = "./module/vpc"

}

module "eks" {
    source = "./module/eks"

    cluster_name = var.cluster_name
    subnet_ids   = module.vpc.subnets_eks
}

module "rds" {
    source = "./module/rds"

    
    db_subnet_group_name = module.vpc.db_subnet_group_name
    db_security_group_ids = [module.vpc.db_sg_id]
    db_name = "simple_social_db"

}

module "env_data_api" {
    source = "./module/env_data"
    config_map_name = "env_config_map_api"
    namespace       = "simple_social"
    labels = {
        app = "simple-social-config"
    }
    config_map_data = {
        DB_URL  = module.rds.db_instance_endpoint
        DB_NAME = module.rds.db_name
        DB_USER = module.rds.db_username
    }

    secret_name = "simple-social-secrets"
    secret_data = {
        DB_PASS = module.rds.db_password
    }

    secret_data_revision = module.rds.db_password_version

  
}

module "env_data_fronend" {
    source = "./module/env_data"
    config_map_name = "env_config_map_frontend"
    namespace       = "simple_social"
    labels = {
        app = "simple-social-config"
    }
    config_map_data = {
        API_URL = "${module.k8s_manifest_api.service_name}:${module.k8s_manifest_api.service_port}"
    }

}

module "k8s_manifest_api" {
    source = "./module/k8s_manifest"
    namespace     = var.namespace
    deployment_name = "simple-social-api-deployment"
    labels = {
        app = "simple-social-api"
    }
    container_image = "docker.io/0142365870/simple_social_api:latest"
    container_name  = "simple-social-api"
    container_port  = 8000
    target_port = 8000
    replicas        = 2
    config_map_name = module.env_data_api.config_map_name
    secret_name     = module.env_data_api.secret_name
    service_name    = "simple-social-api"
    service_port    = 8000
    
}

module "k8s_manifest_frontend" {
    source = "./module/k8s_manifest"
    namespace     = var.namespace
    deployment_name = "simple-social-frontend-deployment"
    labels = {
        app = "simple-social-frontend"
    }
    container_image = "docker.io/0142365870/simple_social_frontend:latest"
    container_name  = "simple-social-frontend"
    container_port  = 80
    target_port = 80
    replicas        = 2
    config_map_name = module.env_data_fronend.config_map_name
    service_name    = "simple-social-frontend"
    service_port    = 80
    
}

module "k8s_ingress" {
    source = "./module/k8s_ingress"
    namespace     = var.namespace
    ingress_name  = "simple-social-ingress"
    host_name     = null
    path          = "/"
    path_type     = "Prefix"
    annotations   = {
        "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
        app = "simple-social-ingress"
    }
    service_name  = module.k8s_manifest_frontend.service_name
    service_port  = module.k8s_manifest_frontend.service_port

}



