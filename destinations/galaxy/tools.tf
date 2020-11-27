locals {
  repos = yamldecode(data.local_file.tool_list.content)["tools"]
  duplicates = ["toolshed.g2.bx.psu.edu/repos/nml/bundle_collections/705ebd286b57"]
}

resource "docker_image" "irida" {
  name = "${local.irida_image}:${var.image_tag}"
}

resource "docker_container" "tool_list" {
  image = docker_image.irida.latest
  name = "irida-get-tool-list${local.name_suffix}"
  restart = "no"
  must_run = false
  attach = true
  command = ["cp", "${local.config_dir}/tool-list.yml", "/mnt/tool-list.yml"]
  mounts {
    source = abspath(path.root)
    target = "/mnt"
    type = "bind"
  }
}

data "local_file" "tool_list" {
  depends_on = [docker_container.tool_list]
  filename = "${abspath(path.root)}/tool-list.yml"
}

resource "galaxy_repository" "repositories" {
  for_each = { for k, v in zipmap([for repo in local.repos: "${regex("(?:https?://)?([^/]+)", repo.tool_shed_url)[0]}/repos/${repo.owner}/${repo.name}/${repo.revisions[0]}"], local.repos): k => v if !contains(local.duplicates, k) }
  tool_shed = regex("(?:https?://)?([^/]+)", each.value.tool_shed_url)[0]
  owner = each.value.owner
  name = each.value.name
  changeset_revision = each.value.revisions[0]
}