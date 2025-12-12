module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.0"

  role_name = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  depends_on = [ module.eks ]
}

resource "kubernetes_service_account_v1" "k8s_service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
    }
  }
  depends_on = [ module.alb_irsa ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.9.1"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_irsa.iam_role_arn
  }
  
 depends_on = [ kubernetes_service_account_v1.k8s_service_account ]

}



resource "kubernetes_namespace_v1" "simple-social" {
    metadata {
        name = "simple-social"
        
    }
    depends_on = [ module.eks ]

}

resource "kubernetes_secret_v1" "db-credentials" {
    metadata {
        name      = "db-credentials"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    data = {
        DB_USER = local.db_username
        DB_PASS = random_password.db_password.result
    }
    type = "Opaque"


    depends_on = [ module.eks, module.vpc, random_password.db_password ]

}

resource "kubernetes_config_map_v1" "db-config" {
    metadata {
        name      = "db-config"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    data = {
        DB_URL = module.mysql_rds.db_instance_address
        DB_NAME = local.db_name
        
    }
    depends_on = [ module.eks, module.vpc ]
  
}

resource "kubernetes_config_map_v1" "frontend" {
    metadata {
        name      = "frontend-config"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    data = {
        API_URL = "backend-service.simple-social.svc.cluster.local"
    }
    depends_on = [ module.eks, module.vpc ]
}

resource "kubernetes_deployment_v1" "simple-social-api" {
    metadata {
        name      = "simple-social-api"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "simple-social-api"
            }
        }
        template {
            metadata {
                labels = {
                    app = "simple-social-api"
                }
            }
            spec {
                container {
                    name  = "simple-social-api"
                    image = "0142365870/simple_social_api:latest"
                    image_pull_policy = "Always"
                    port {
                        container_port = 8000
                    }
                    env_from {
                        config_map_ref {
                            name = kubernetes_config_map_v1.db-config.metadata[0].name
                        }
                    }
                    env_from {
                        secret_ref {
                            name = kubernetes_secret_v1.db-credentials.metadata[0].name
                        }
                    }
                }
            }
        }
    }
    
  depends_on = [ module.eks, module.vpc ]
}

resource "kubernetes_service_v1" "simple-social-api" {
    metadata {
        name      = "backend-service"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    spec {
        selector = {
            app = "simple-social-api"
        }
        port {
            port        = 80
            target_port = 8000
        }
        type = "ClusterIP"
    }
    
  depends_on = [ module.eks, module.vpc]
}

resource "kubernetes_deployment_v1" "simple-social-frontend" {
    metadata {
        name      = "simple-social-frontend"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "simple-social-frontend"
            }
        }
        template {
            metadata {
                labels = {
                    app = "simple-social-frontend"
                }
            }
            spec {
                container {
                    name  = "simple-social-frontend"
                    image = "0142365870/simple_social_frontend:latest"
                    image_pull_policy = "Always"
                    port {
                        container_port = 8501
                    }
                    env_from {
                        config_map_ref {
                            name = kubernetes_config_map_v1.frontend.metadata[0].name
                        }
                    }
                }
            }
        }
    }
    
  depends_on = [ module.eks, module.vpc ]
}

resource "kubernetes_service_v1" "simple-social-frontend" {
    metadata {
        name      = "simple-social-frontend"
        namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    }
    spec {
        selector = {
            app = "simple-social-frontend"
        }
        port {
            port        = 80
            target_port = 8501
        }
        type = "ClusterIP"
    }
    depends_on = [ module.eks, module.vpc ]
  
}



resource "kubernetes_ingress_v1" "simple-social-ingress" {
  metadata {
    name      = "simple-social-ingress"
    namespace = kubernetes_namespace_v1.simple-social.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/manage-backend-security-group-rules" = "false"
      "alb.ingress.kubernetes.io/delete-automation-enabled" = "true"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service_v1.simple-social-frontend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.aws_load_balancer_controller, kubernetes_service_v1.simple-social-frontend
  ]
}