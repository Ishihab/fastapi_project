output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = kubernetes_ingress_v1.simple-social-ingress.status[0].load_balancer[0].ingress[0].hostname
  
}