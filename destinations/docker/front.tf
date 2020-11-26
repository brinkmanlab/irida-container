resource "docker_container" "irida_front" {
  depends_on = [docker_container.wait_for_db, docker_container.init_data]
  name       = "${local.app_name}_front${local.name_suffix}"
  image      = docker_image.irida_app.latest
  hostname   = "irida-app-front"
  domainname = "irida-app-front"
  restart    = "unless-stopped"
  must_run   = true
  #user       = "irida:irida"
  env = [
    "JAVA_OPTS=-D${join(" -D", compact(local.irida_config))} -Dspring.profiles.active=${join(",", local.profiles.front)}",
  ]
  ports {
    external = var.host_port
    internal = 8080
  }
  networks_advanced {
    name = local.network
    aliases = ["irida-app-front"]
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

resource "docker_image" "wait_for_init" {
  name = "quay.io/biocontainers/curl:7.62.0"
}

resource "docker_container" "wait_for_init" {
  depends_on = [docker_container.irida_front]
  image = docker_image.wait_for_init.latest
  name = "wait_for_init"
  must_run = false
  attach = true
  command = ["bash", "-c", "until curl -sS --fail -o /dev/null 'http://irida-app-front:8080/'; do sleep 1; done"]
  networks_advanced {
    name = local.network
  }
}