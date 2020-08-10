variable "image_tag" {
  type    = string
  default = "latest"
}

variable "db_conf" {
  type = object({
        scheme = string
    host = string
    name = string
    user = string
    pass = string
  })
  default = null
  description = "Database configuration overrides"
}

variable "object_store_access_key" {
  type        = string
  default     = ""
  description = "Object store access key"
}

variable "object_store_secret_key" {
  type        = string
  default     = ""
  description = "Object store secret key"
}