import os
from xia_module import Module


class Pypi(Module):
    module_name = "module-pypi"

    @classmethod
    def _check_package(cls):
        for root, dirs, files in os.walk(os.getcwd()):
            if '__init__.py' in files:
                return True
        return False

    def _build_template_module(self, **kwargs):
        if self._check_package():
            return
        package_name = kwargs.get("package_name", os.path.basename(os.getcwd()))
        os.makedirs(package_name.replace("-", "_"), exist_ok=True)
        template = self.env.get_template("__init__.py.jinja")
        content = template.render(**kwargs)
        init_file_name = f'{package_name.replace("-", "_")}/__init__.py'
        with open(init_file_name, "w") as fp:
            fp.write(content)
        self.git_add(init_file_name)

    def _build_template(self, **kwargs):
        # Step 1: Build
        self._build_template_module(**kwargs)