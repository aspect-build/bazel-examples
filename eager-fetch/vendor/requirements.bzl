# Follow documentation in https://github.com/bazelbuild/rules_python/blob/main/docs/pip.md#vendoring-the-requirementsbzl-file
# to update this file

load("@rules_python//python/pip_install:pip_repository.bzl", "whl_library")

all_requirements = []

all_whl_requirements = []

_packages = []
_config = {"python_interpreter": "python3", "python_interpreter_target": None, "quiet": True, "timeout": 600, "repo": "pip_deps", "isolated": True, "extra_pip_args": [], "pip_data_exclude": [], "enable_implicit_namespace_pkgs": False, "environment": {}, "repo_prefix": "pip_deps_"}
_annotations = {}

def _clean_name(name):
    return name.replace("-", "_").replace(".", "_").lower()

def requirement(name):
    return "@pip_deps_" + _clean_name(name) + "//:pkg"

def whl_requirement(name):
    return "@pip_deps_" + _clean_name(name) + "//:whl"

def data_requirement(name):
    return "@pip_deps_" + _clean_name(name) + "//:data"

def dist_info_requirement(name):
    return "@pip_deps_" + _clean_name(name) + "//:dist_info"

def entry_point(pkg, script = None):
    if not script:
        script = pkg
    return "@pip_deps_" + _clean_name(pkg) + "//:rules_python_wheel_entry_point_" + script

def _get_annotation(requirement):
    # This expects to parse `setuptools==58.2.0     --hash=sha256:2551203ae6955b9876741a26ab3e767bb3242dafe86a32a749ea0d78b6792f11`
    # down wo `setuptools`.
    name = requirement.split(" ")[0].split("=")[0]
    return _annotations.get(name)

def install_deps():
    for name, requirement in _packages:
        whl_library(
            name = name,
            requirement = requirement,
            annotation = _get_annotation(requirement),
            **_config
        )
