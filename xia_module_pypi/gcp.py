from xia_module_pypi import Pypi


class PypiGcp(Pypi):
    activate_depends = ["gcp-module-project", "module-application-state-gcs"]
    module_name = "gcp-module-pypi"
