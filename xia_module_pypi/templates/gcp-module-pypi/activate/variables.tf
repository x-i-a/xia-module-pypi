variable "landscape_file" {
  type = string
  description = "Landscape file"
  default = "../../../config/landscape.yaml"
}

variable "applications_file" {
  type = string
  description = "Application config file"
  default = "../../../config/applications.yaml"
}

variable "modules_file" {
  type = string
  description = "Module config file"
  default = "../../../config/modules.yaml"
}

variable "project_file" {
  type = string
  description = "Project config file"
  default = "../../../config/gcp-project.yaml"
}