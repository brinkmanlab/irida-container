output "db_root" {
  value       = random_password.db_root.result
  sensitive   = true
  description = "Password for root user in DB container"
}

output "network" {
  value = local.network
  description = "Network name. If var.network not provided, returns generated network name, otherwise same as var.network"
}