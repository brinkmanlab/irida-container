resource "docker_container" "irida_singleton" {
  depends_on = [docker_container.wait_for_init]
  name       = "${local.app_name}_singleton${local.name_suffix}"
  image      = docker_image.irida_app.latest
  hostname   = "irida-app-singleton"
  domainname = "irida-app-singleton"
  restart    = "unless-stopped"
  must_run   = true
  #user       = "irida:irida"
  env = [
    "JAVA_OPTS=-D${join(" -D", compact(local.irida_config))} -Dspring.profiles.active=${join(",", local.profiles.singleton)}",
  ]
  networks_advanced {
    name = local.network
    aliases = ["irida-app-singleton"]
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
}