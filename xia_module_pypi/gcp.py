from xia_module_pypi import Pypi


class PypiGcp(Pypi):
    module_name = "gcp-module-pypi"
    activate_depends = ["gcp-module-project"]
