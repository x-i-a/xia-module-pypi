terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

locals {
  module_name = replace(substr(basename(path.module), 9, length(basename(path.module)) - 9), "-", "_")
  project = yamldecode(file(var.project_file))
  landscape = yamldecode(file(var.landscape_file))
  applications = yamldecode(file(var.applications_file))
  project_prefix = local.project["project_prefix"]
  environment_dict = local.landscape["environments"]
  application_list = local.landscape["modules"][local.module_name]["applications"]
  repository_region = local.landscape["modules"][local.module_name]["repository_region"]
}

locals {
  all_role_attribution = toset(flatten([
    for env_name, env in local.environment_dict : [
      for app_name in local.application_list : {
        app_name          = app_name
        env_name          = env_name
        project_id        = "${local.project_prefix}${env_name}"
      }
    ]
  ]))
}

resource "google_project_service" "artifact_registry_api" {
  for_each = local.environment_dict

  project = "${local.project_prefix}${each.key}"
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "pypi_official" {
  for_each = local.environment_dict

  project       = "${local.project_prefix}${each.key}"
  location      = local.repository_region
  repository_id = "pypi-official"
  format        = "PYTHON"
  mode          = "REMOTE_REPOSITORY"
  description   = "PyPI repository proxy"
  remote_repository_config {
    description = "Official Pypi Repository"
    python_repository {
      public_repository = "PYPI"
    }
  }

  depends_on = [google_project_service.artifact_registry_api]
}

resource "google_artifact_registry_repository" "pypi_custom" {
  for_each = local.environment_dict

  project       = "${local.project_prefix}${each.key}"
  location      = local.repository_region
  repository_id = "pypi-custom"
  format        = "PYTHON"
  description   = "Custom PyPI repository"

  depends_on = [google_project_service.artifact_registry_api]
}

resource "google_artifact_registry_repository" "pypi" {
  for_each = local.environment_dict

  project       = "${local.project_prefix}${each.key}"
  location      = local.repository_region
  repository_id = "pypi"
  description   = "PyPI repository"
  format        = "PYTHON"
  mode          = "VIRTUAL_REPOSITORY"
  virtual_repository_config {
    upstream_policies {
      id          = "pypi-official"
      repository  = google_artifact_registry_repository.pypi_official[each.key].id
      priority    = 20
    }
    upstream_policies {
      id          = "pypi-custom"
      repository  = google_artifact_registry_repository.pypi_custom[each.key].id
      priority    = 10
    }
  }
  depends_on = [google_artifact_registry_repository.pypi_custom, google_artifact_registry_repository.pypi_official]
}

resource "google_project_iam_custom_role" "gcp_module_python_deployer_role" {
  for_each = local.environment_dict

  project     = "${local.project_prefix}${each.key}"
  role_id     = "gcpModulePythonDeployer"
  title       = "GCP Python Module Deployer Role"
  description = "GCP Python Module Deployer Role"
  permissions = [
    "artifactregistry.packages.get",
    "artifactregistry.packages.list",
    "artifactregistry.projectsettings.get",
    "artifactregistry.pythonpackages.get",
    "artifactregistry.pythonpackages.list",
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.uploadArtifacts",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.list",
    "artifactregistry.repositories.listEffectiveTags",
    "artifactregistry.repositories.listTagBindings",
    "artifactregistry.repositories.readViaVirtualRepository"
  ]
}

resource "google_artifact_registry_repository_iam_member" "gcp_module_python_deployer_role_member" {
  for_each = { for s in local.all_role_attribution : "${s.app_name}-${s.env_name}" => s }

  project       = each.value["project_id"]
  location      = google_artifact_registry_repository.pypi_custom[each.value["env_name"]].location
  repository    = google_artifact_registry_repository.pypi_custom[each.value["env_name"]].repository_id
  role          = google_project_iam_custom_role.gcp_module_python_deployer_role[each.value["env_name"]].id
  member        = "serviceAccount:wip-${each.value["app_name"]}-sa@${each.value["project_id"]}.iam.gserviceaccount.com"

  depends_on = [google_project_iam_custom_role.gcp_module_python_deployer_role]
}

resource "github_actions_environment_variable" "action_var_gcp_repo_region" {
  for_each = { for s in local.all_role_attribution : "${s.app_name}-${s.env_name}" => s }

  repository       = local.applications[each.value["app_name"]]["repository_name"]
  environment      = each.value["env_name"]
  variable_name    = "GCP_REPO_REGION"
  value            = local.repository_region
}