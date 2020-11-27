terraform {
  required_providers {
    galaxy = {
      source = "brinkmanlab/galaxy"
    }
    docker = {
      source = "terraform-providers/docker"
    }
  }
  required_version = ">= 0.13"
}
