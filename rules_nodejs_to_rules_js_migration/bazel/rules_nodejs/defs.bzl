load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_to_bin")
load("@build_bazel_rules_nodejs//:index.bzl", "js_library")
load("@npm//@bazel/typescript:index.bzl", _ts_project = "ts_project")

def ts_project(name, **kwargs):
    """
    rules_nodejs ts_project wrapper that makes its output easily adapted to rules_js

    Args:
        name: name
        **kwargs: other args
    """
    srcs = kwargs.pop("srcs", [])
    visibility = kwargs.pop("visibility", [])

    copy_to_bin_target = "{}_copy_srcs_to_bin".format(name)
    ts_project_target = "{}_ts_project".format(name)

    copy_to_bin(
        name = copy_to_bin_target,
        srcs = srcs,
        # only build if downstream is built
        tags = ["manual"],
    )

    _ts_project(
        name = ts_project_target,
        srcs = srcs,
        # only build if downstream is built
        tags = ["manual"],
        **kwargs
    )

    js_library(
        name = name,
        srcs = [copy_to_bin_target],
        deps = [ts_project_target],
        visibility = visibility,
    )
