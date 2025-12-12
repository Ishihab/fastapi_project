resource "null_resource" "remove_ingress_finalizer" {
    
    triggers = {
      ingress_name = kubernetes_ingress_v1.simple-social-ingress.metadata[0].name
      namespace    = kubernetes_namespace_v1.simple-social.metadata[0].name
    }

    provisioner "local-exec" {
      command = <<EOT
      kubectl patch ingress ${self.triggers.ingress_name} -n ${self.triggers.namespace} -p '{"metadata":{"finalizers":[]}}' --type=merge || true
      EOT
    }
  depends_on = [ kubernetes_ingress_v1.simple-social-ingress ]
}