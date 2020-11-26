variable "network" {
  type        = string
  default     = ""
  description = "Docker network name"
}

variable "host_port" {
  type = number
  description = "Host port to expose galaxy service"
}

variable "user_data_volume" {
  default = null
  description = "Provide a user data volume shared by Galaxy"
}