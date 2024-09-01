from xia_module_pypi.pypi import Pypi
from xia_module_pypi.gcp import PypiGcp

modules = {
    "module-pypi": "Pypi",
    "gcp-module-pypi": "PypiGcp"
}

__all__ = [
    "Pypi",
    "PypiGcp",
]

__version__ = "0.0.11"
