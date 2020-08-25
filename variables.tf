variable "destination" {
  type        = string
  default     = "aws"
  description = "Deployment destination"
}

variable "instance" {
  type        = string
  default     = ""
  description = "Specify a unique instance name for this deployment"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "create_cloud" {
  type = bool
  default = true
  description = "Create underlying cloud resources"
}

variable "db_conf" {
  type = object({
    scheme = string
    host   = string
    name   = string
    user   = string
    pass   = string
  })
  default     = null
  description = "Database configuration overrides"
}

variable "email" {
  type        = string
  default     = "irida@irida.ca"
  description = "Email address to send automated emails from"
}

variable "base_url" {
  type        = string
  default     = ""
  description = "The externally visible URL for accessing this instance of IRIDA. This key is used by the e-mailer when sending out e-mail notifications (password resets, for example) and embeds this URL directly in the body of the e-mail."
}