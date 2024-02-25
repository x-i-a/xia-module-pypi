from xia_module import Module


class PypiGcp(Module):
    module_name = "gcp-module-pypi"
    activate_depends = ["gcp-module-project"]
