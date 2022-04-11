variable "instance" {
  type = string
  description = "Unique deployment instance identifier"
}

variable "debug" {
  type = bool
  default = false
  description = "Enabling will put the deployment into a mode suitable for debugging"
}

variable "email" {
  type = string
  description = "Email address to send automated emails from"
}

variable "region" {
  type = string
  description = "AWS region to deploy into"
}

variable "base_url" {
  type        = string
  description = "The externally visible URL for accessing this instance of IRIDA. This key is used by the e-mailer when sending out e-mail notifications (password resets, for example) and embeds this URL directly in the body of the e-mail."
}