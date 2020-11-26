locals {
  user_data_volume = var.user_data_volume != null ? var.user_data_volume : docker_volume.user_data[0]
}

resource "docker_volume" "user_data" {
  count = var.user_data_volume == null ? 1 : 0
  name = "${var.user_data_volume_name}${local.name_suffix}"
}

resource "docker_volume" "db_data" {
  name = "${var.db_data_volume_name}${local.name_suffix}"
}

resource "docker_container" "init_data" {
  image = docker_image.irida_app.latest
  name = "irida-init-storage"
  command = ["sh", "-c", "cp -av ${local.data_dir}/* /mnt"]
  user = "1000:1000"
  must_run = false
  attach = true
  mounts {
    source = local.user_data_volume.name
    target = "/mnt"
    type   = "volume"
  }
}