output "extra_mounts" {
  value = {
    "irida" = {
      claim_name = kubernetes_persistent_volume_claim.user_data.metadata.0.name
      path = var.data_dir
      read_only = true
    }
  }
}

output "extra_job_mounts" {
  value = ["${kubernetes_persistent_volume_claim.user_data.metadata.0.name}:${var.data_dir}"]
}

output "claim_name" {
  value = kubernetes_persistent_volume_claim.user_data.metadata.0.name
}