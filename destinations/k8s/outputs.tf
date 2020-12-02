output "endpoint" {
  value = kubernetes_service.irida.load_balancer_ingress.0.hostname
}

output "namespace" {
  value = local.namespace
}