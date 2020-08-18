terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    docker = {
      source = "terraform-providers/docker"
    }
    restapi = {
      source  = "github.com/Mastercard/restapi"
      version = ">= 1.13.0"
    }
  }
  required_version = ">= 0.13"
}
