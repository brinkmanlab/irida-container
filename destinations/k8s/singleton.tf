resource "kubernetes_deployment" "irida_singleton" {
  wait_for_rollout = !var.debug
  depends_on = [kubernetes_deployment.irida_front]
  metadata {
    name      = "${local.app_name}-singleton"
    namespace = local.instance
    labels = {
      App                          = "${local.app_name}-singleton"
      "app.kubernetes.io/name"     = "${local.app_name}-singleton"
      "app.kubernetes.io/instance" = "${local.app_name}-singleton"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "singleton"
      "app.kubernetes.io/part-of"    = "irida"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas          = lookup(local.replicates, "singleton", 1)
    min_ready_seconds = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = "${local.app_name}-singleton"
      }
    }
    template {
      metadata {
        labels = {
          App = "${local.app_name}-singleton"
        }
      }
      spec {
        container {
          image = "${var.irida_image}:${var.image_tag}"
          name  = "irida-singleton"
          env {
            name  = "JAVA_OPTS"
            value = "-D${join(" -D", compact(local.irida_config))} -Dspring.profiles.active=${join(",", local.profiles.singleton)}"
          }

          resources {
            limits {
              cpu    = "2"
              memory = "2Gi"
            }
            requests {
              cpu    = "1"
              memory = "1Gi"
            }
          }
          volume_mount {
            mount_path = local.tmp_dir
            name       = "tmp"
          }
          volume_mount {
            mount_path = local.data_dir
            name       = "data"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.user_data.metadata.0.name
          }
        }
        # TODO Configure
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}