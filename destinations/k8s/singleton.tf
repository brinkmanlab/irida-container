resource "kubernetes_deployment" "irida_singleton" {
  wait_for_rollout = !var.debug
  depends_on = [kubernetes_deployment.irida_front]
  metadata {
    name      = "${local.app_name}-singleton"
    namespace = local.namespace.metadata.0.name
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
          image = "${local.irida_image}:${var.image_tag}"
          name  = "irida-singleton"
          env {
            name  = "JAVA_OPTS"
            value = "-Dirida.db.profile=${var.debug ? "dev" : "prod"} -Dspring.profiles.active=${join(",", local.profiles.singleton)}"
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
          volume_mount {
            mount_path = local.config_dir
            name = "config"
            read_only = true
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
            claim_name = var.claim_name
          }
        }
        volume {
          name = "config"
          secret {
            secret_name = kubernetes_secret.config.metadata.0.name
          }
        }
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}