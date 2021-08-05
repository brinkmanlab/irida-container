resource "kubernetes_job" "plugins" {
  metadata {
    generate_name = "load-plugins-"
    namespace = local.namespace.metadata.0.name
  }
  spec {
    template {
      metadata {}
      spec {
        automount_service_account_token = false
        container {
          name              = "load-plugins"
          command           = [ "bash", "-c", "mkdir -p '${local.data_dir}/plugins'; rm -rf '${local.data_dir}'/plugins/*; ${local.plugin_curl_cmd}"]
          image             = "${local.irida_image}:${var.image_tag}"
          image_pull_policy = var.debug ? "Always" : null
          volume_mount {
            mount_path = local.data_dir
            name       = "data"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = var.claim_name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 1
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
  }
}
