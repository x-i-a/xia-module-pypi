provider "google" {
  alias = "gcp-pypi"
}

provider "github" {
  alias = "gcp-pypi"
  owner = lookup(yamldecode(file("../../../config/core/github.yaml")), "github_owner", null)
}


module "gcp_module_pypi" {
  providers = {
    google = google.gcp-pypi
    github = github.gcp-pypi
  }

  source = "../../modules/gcp-module-pypi"

}
