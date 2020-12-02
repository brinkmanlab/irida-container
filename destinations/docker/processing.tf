resource "docker_container" "irida_processing" {
  depends_on = [docker_container.wait_for_init]
  name       = "${local.app_name}_processing${local.name_suffix}"
  image      = docker_image.irida_app.latest
  hostname   = "irida-app-processing"
  domainname = "irida-app-processing"
  restart    = "unless-stopped"
  must_run   = true
  #user       = "irida:irida"
  env = [
    "JAVA_OPTS=-Dspring.profiles.active=${join(",", local.profiles.processing)}",
  ]
  networks_advanced {
    name = local.network
    aliases = ["irida-app-processing"]
  }
  mounts {
    source = local.user_data_volume.name
    target = local.data_dir
    type   = "volume"
  }
  mounts {
    target = local.tmp_dir
    type = "volume"
  }
  upload {
    file = "${local.config_dir}/irida.conf"
    content = local.irida_config
  }
  upload {
    file = "${local.config_dir}/web.conf"
    content = local.web_config
  }
}