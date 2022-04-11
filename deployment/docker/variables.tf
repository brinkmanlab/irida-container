variable "instance" {
  type = string
  description = "Unique deployment instance identifier"
}

variable "debug" {
  type = bool
  description = "Enabling will put the deployment into a mode suitable for debugging"
}

variable "email" {
  type = string
  description = "Email address to send automated emails from"
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