locals {
  base_url = var.base_url
}

resource "kubernetes_deployment" "irida" {
  depends_on = [var.depends]
  for_each = local.profiles
  metadata {
    name = "${var.app_name}${var.name_suffix}-${each.key}"
    namespace = var.instance
    labels = {
      App = "${var.app_name}${var.name_suffix}-${each.key}"
      "app.kubernetes.io/name" = "${var.app_name}-${each.key}"
      "app.kubernetes.io/instance" = "${var.app_name}${var.name_suffix}-${each.key}"
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component" = each.key
      "app.kubernetes.io/part-of" = "irida"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas          = lookup(local.replicates, each.key, 1)
    min_ready_seconds = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        App = "${var.app_name}${var.name_suffix}-${each.key}"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.app_name}${var.name_suffix}-${each.key}"
        }
      }
      spec {
        container {
          image = "${var.irida_image}:${var.image_tag}"
          name  = "irida${var.name_suffix}-${each.key}"
          env {
            name  = "JAVA_OPTS"
            value = "-D${join(" -D", compact(local.irida_config))} -Dspring.profiles.active=${join(",", each.value)}"
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
            mount_path = var.tmp_dir
            name       = "tmp"
          }
          volume_mount {
            mount_path = var.data_dir
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
            claim_name = "irida-user-data"
          }
        }
        # TODO Configure
        # https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#volume-2
      }
    }
  }
}

#resource "kubernetes_horizontal_pod_autoscaler" "irida" {
#  for_each = local.profiles
#  metadata {
#    name = "irida${var.name_suffix}-${each.key}"
#  }
#
#  spec {
#    max_replicas = 10
#    min_replicas = 1
#
#    scale_target_ref {
#      kind = "Deployment"
#      name = "${var.app_name}${var.name_suffix}-${each.key}"
#    }
#  }
#}


resource "kubernetes_service" "irida" {
  metadata {
    name = "${var.app_name}${var.name_suffix}"
    namespace = var.instance
  }
  spec {
    selector = {
      App = "${var.app_name}${var.name_suffix}-front"
    }
    port {
      protocol = "TCP"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"  # https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  }
}