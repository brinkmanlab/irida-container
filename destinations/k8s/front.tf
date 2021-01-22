resource "kubernetes_deployment" "irida_front" {
  wait_for_rollout = true
  metadata {
    name      = "${local.app_name}-front"
    namespace = local.namespace.metadata.0.name
    labels = {
      App                          = "${local.app_name}-front"
      "app.kubernetes.io/name"     = "${local.app_name}-front"
      "app.kubernetes.io/instance" = "${local.app_name}-front"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "front"
      "app.kubernetes.io/part-of"    = "irida"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas          = lookup(local.replicates, "front", 1)
    min_ready_seconds = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = "${local.app_name}-front"
      }
    }
    template {
      metadata {
        labels = {
          App = "${local.app_name}-front"
        }
      }
      spec {
        automount_service_account_token = false
        container {
          image = "${local.irida_image}:${var.image_tag}"
          name  = "irida-front"
          env {
            name  = "JAVA_OPTS"
            value = "-Dirida.db.profile=${var.debug ? "dev" : "prod"} -Dspring.profiles.active=${join(",", local.profiles.front)}"
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "8080"
              scheme = "HTTP"
            }
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "2Gi"
            }
            requests = {
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

#resource "kubernetes_horizontal_pod_autoscaler" "irida" {
#  for_each = local.profiles
#  metadata {
#    name = "irida${local.name_suffix}-front"
#  }
#
#  spec {
#    max_replicas = 10
#    min_replicas = 1
#
#    scale_target_ref {
#      kind = "Deployment"
#      name = "${local.app_name}${local.name_suffix}-front"
#    }
#  }
#}


resource "kubernetes_service" "irida" {
  metadata {
    name      = local.app_name
    namespace = local.namespace.metadata.0.name
    annotations = var.lb_annotations
  }
  spec {
    selector = {
      App = "${local.app_name}-front"
    }
    port {
      name = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer" # https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  }
}