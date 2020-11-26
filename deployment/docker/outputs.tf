output "galaxy_admin_password" {
  value = module.admin_user.password
  sensitive = true
}
output "galaxy_admin_api_key" {
  value = module.admin_user.api_key
  sensitive = true
}
output "db_root" {
  value = module.irida.db_root
  sensitive = true
}