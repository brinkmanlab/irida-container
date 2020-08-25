locals {
  ansible        = yamldecode(file("${path.module}/vars.yml"))

  app_name              = local.ansible.containers.app.name
  db_name               = local.ansible.containers.db.name
  data_dir              = local.ansible.paths.data
  tmp_dir               = local.ansible.paths.tmp
  user_data_volume_name = local.ansible.volumes.user_data.name
  db_data_volume_name   = local.ansible.volumes.db_data.name
  irida_image = var.irida_image != null ? var.irida_image : "brinkmanlab/${local.app_name}"

  name_suffix = var.instance == "" ? "" : "-${var.instance}"
  db_conf = var.db_conf != null ? var.db_conf : {
    scheme = "mysql"
    host   = var.db_name
    name   = "irida${local.name_suffix}"
    user   = "irida"
    pass   = random_password.db_password[0].result
  }
  profiles = {
    front      = ["web"]
    processing = ["processing"]
    singleton  = ["email", "analysis", "sync", "ncbi"]
  }
  replicates = {
    front      = var.front_replicates
    processing = var.processing_replicates
    singleton  = 1 # MUST ALWAYS BE 1
  }
  irida_config = [
    "server.base.url='${local.base_url}'",
    "jdbc.url='jdbc:${local.db_conf.scheme}://${local.db_conf.host}/${local.db_conf.name}'",
    "jdbc.username='${local.db_conf.user}'",
    "jdbc.password='${local.db_conf.pass}'", # TODO use k8s secret?
    var.galaxy_api_key == "" ? "" : "galaxy.execution.apiKey='${var.galaxy_api_key}'",
    var.galaxy_user_email == "" ? "" : "galaxy.execution.email='${var.galaxy_user_email}'",
    var.mail_from == "" ? "" : "mail.server.email='${var.mail_from}'",
    var.mail_user == "" ? "" : "mail.server.username='${var.mail_user}'",
    var.mail_password == "" ? "" : "mail.server.password='${var.mail_password}'", # TODO use k8s secret?
    var.ncbi_user == "" ? "" : "ncbi.upload.user='${var.ncbi_user}'",
    var.ncbi_password == "" ? "" : "ncbi.upload.password='${var.ncbi_password}'",
    var.help_title == "" ? "" : "help.page.title='${var.help_title}'",
    var.help_url == "" ? "" : "help.page.url='${var.help_url}'",
    var.help_email == "" ? "" : "help.contact.email='${var.help_email}'",
    var.analysis_warning == "" ? "" : "irida.analysis.warning='${var.analysis_warning}'",
    length(var.hide_workflows) == 0 ? "" : "irida.workflow.types.disabled='${join(",", var.hide_workflows)}'",
  ]
}

resource "random_password" "db_password" {
  count   = var.db_conf == null ? 1 : 0
  length  = 16
  special = false
}

variable "instance" {
  type        = string
  default     = ""
  description = "Unique deployment instance identifier"
}

variable "app_name" {
  type        = string
  default     = null
  description = "Application container name"
}

variable "db_name" {
  type        = string
  default     = null
  description = "Database container name"
}

variable "user_data_volume_name" {
  type        = string
  default     = null
  description = "User data volume name"
}

variable "db_data_volume_name" {
  type        = string
  default     = null
  description = "Database volume name"
}

variable "data_dir" {
  type        = string
  default     = null
  description = "Path to user data within container"
}

variable "tmp_dir" {
  type        = string
  default     = null
  description = "Path to mount temporary space into container"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Tag for irida_app image"
}

variable "front_replicates" {
  type        = number
  default     = 1
  description = "Number of replicate front end instances"
}

variable "processing_replicates" {
  type        = number
  default     = 1
  description = "Number of replicate processing instances"
}

variable "base_url" {
  type        = string
  default     = ""
  description = "The externally visible URL for accessing this instance of IRIDA. This key is used by the e-mailer when sending out e-mail notifications (password resets, for example) and embeds this URL directly in the body of the e-mail."
}

variable "galaxy_api_key" {
  type        = string
  description = "The API key of an account to run workflows in Galaxy. This does not have to be an administrator account."
}

variable "galaxy_user_email" {
  type        = string
  description = "The email address of an account to run workflows in Galaxy"
}

variable "mail_from" {
  type        = string
  description = "Email address to send notifications as"
}

variable "mail_user" {
  type        = string
  description = "User name for SMTP server"
}

variable "mail_password" {
  type        = string
  description = "Password for SMTP server"
}

variable "ncbi_user" {
  type        = string
  default     = ""
  description = "FTP username for bulk SRA uploads"
}

variable "ncbi_password" {
  type        = string
  default     = ""
  description = "FTP password for bulk SRA uploads"
}

variable "help_title" {
  type        = string
  default     = ""
  description = "The title for an external help resource"
}

variable "help_url" {
  type        = string
  default     = ""
  description = "The link for an external help resource"
}

variable "help_email" {
  type        = string
  default     = ""
  description = "The e-mail address for contacting an administrator for help"
}

variable "analysis_warning" {
  type        = string
  default     = ""
  description = "Display a dismissable warning above all analysis results and metadata pages"
}

variable "hide_workflows" {
  type        = list(string)
  default     = []
  description = "A list of workflow types to disable from display in the web interface"
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

variable "irida_image" {
  type        = string
  default     = null
  description = "IRIDA application image name"
}

variable "db_image" {
  type        = string
  default     = "mariadb"
  description = "MariaDB image name (Ignored if destination provides hosted database)"
}

variable "debug" {
  type        = bool
  default     = false
  description = "Enabling will put the deployment into a mode suitable for debugging"
}