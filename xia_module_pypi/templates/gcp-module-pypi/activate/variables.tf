variable "module_name" {
  type = string
  description = "Module Name"
  default = null
}

variable "config_file" {
  type = string
  description = "Project config file"
  default = ""
}

variable "landscape" {
  type = any
  description = "Landscape Configuration"
}

variable "applications" {
  type = map(any)
  description = "Application Configuration"
}

variable "modules" {
  type = any
  description = "Module Configuration"
}

variable "environment_dict" {
  type = map(any)
  description = "Environment Configuration"
}

variable "app_env_config" {
  type = map(any)
  description = "Application Environment Configuration"
}

variable "module_app_to_activate" {
  type = map(list(any))
  description = "Application to be activated for all modules"
}

variable "gcp_projects" {
  type = map(any)
  description = "GCP Project List"
}