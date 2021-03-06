variable "instance" {
  type = string
}

variable "debug" {
  type = bool
}

variable "email" {
  type = string
}

variable "base_url" {
  type        = string
  description = "The externally visible URL for accessing this instance of IRIDA. This key is used by the e-mailer when sending out e-mail notifications (password resets, for example) and embeds this URL directly in the body of the e-mail."
}

variable "host_port" {
  type = number
  description = "Host port to expose galaxy service"
}

variable "docker_gid" {
  type = number
  description = "GID with write permission to /var/run/docker.sock"
}

variable "docker_socket_path" {
  type = string
  description = "Host path to docker socket"
  default = "/var/run/docker.sock"
}