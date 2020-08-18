resource "kubernetes_job" "init_nfs" {
  # Make directories on NFS for instance
  metadata {
    generate_name = "init-nfs-irida-"
    namespace     = local.instance
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "init-nfs-irida"
          image   = "alpine"
          command = ["install", "-d", "-m", "0777", "-o", "1000", "-g", "1000", "${var.data_dir}/${local.instance}/${var.app_name}/"]
          volume_mount {
            mount_path = var.data_dir
            name       = "data"
          }
        }
        node_selector = {
          WorkClass = "service"
        }
        volume {
          name = "data"
          nfs {
            path   = "/"
            server = var.nfs_server
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
  }
}

resource "kubernetes_persistent_volume" "user_data" {
  depends_on = [kubernetes_job.init_nfs]
  metadata {
    name = "${var.app_name}-${var.user_data_volume_name}"
    labels = {
      "app.kubernetes.io/name"     = var.app_name
      "app.kubernetes.io/instance" = var.app_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "pv"
      "app.kubernetes.io/part-of"    = "irida"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    capacity = {
      storage = "1Ti"
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "filestore"
    persistent_volume_source {
      nfs {
        path      = "/${local.instance}/${var.app_name}/"
        server    = var.nfs_server
        read_only = false
      }
    }
    #mount_options = ["all_squash", "anonuid=1000", "anongid=1000"]
  }
}

resource "kubernetes_persistent_volume_claim" "user_data" {
  metadata {
    name      = "${var.app_name}-${var.user_data_volume_name}"
    namespace = local.instance
    labels = {
      "app.kubernetes.io/name"     = var.app_name
      "app.kubernetes.io/instance" = var.app_name
      #"app.kubernetes.io/version" = TODO
      "app.kubernetes.io/component"  = "pvc"
      "app.kubernetes.io/part-of"    = "irida"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "500Gi"
      }
    }
    #selector {
    #  match_labels = {
    #    name = kubernetes_persistent_volume.user_data.metadata.0.name
    #  }
    #}
    storage_class_name = "filestore"
    volume_name        = kubernetes_persistent_volume.user_data.metadata.0.name
  }
}