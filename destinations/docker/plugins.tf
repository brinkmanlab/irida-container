resource "docker_container" "plugins" {
  image      = docker_image.irida_app.latest
  name       = "load-plugins-${local.name_suffix}"
  #user       = "irida:irida"
  attach     = true
  must_run   = false
  entrypoint = [ "bash", "-c", "mkdir -p '${local.data_dir}/plugins'; rm -rf '${local.data_dir}'/plugins/*; ${local.plugin_curl_cmd}"]
  mounts {
    source    = docker_volume.user_data.name
    target    = local.data_dir
    type      = "volume"
    read_only = false
  }
}