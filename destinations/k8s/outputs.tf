output "lb_ip" {
  value = "" #kubernetes_service.irida.load_balancer_ingress[0].ip
}