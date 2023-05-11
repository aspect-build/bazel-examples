load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@rules_python//python:repositories.bzl", "py_repositories")
load("@rules_python_gazelle_plugin//:deps.bzl", py_gazelle_deps = "gazelle_deps")
load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
load("@rules_oci//oci:dependencies.bzl", "rules_oci_dependencies")
load("@rules_oci//oci:repositories.bzl", "LATEST_CRANE_VERSION", "oci_register_toolchains")

def configure():
    go_rules_dependencies()

    go_register_toolchains(version = "1.20.4")

    gazelle_dependencies()

    py_repositories()

    py_gazelle_deps()

    aspect_bazel_lib_dependencies()

    rules_pkg_dependencies()

    rules_oci_dependencies()

    oci_register_toolchains(
        name = "oci",
        crane_version = LATEST_CRANE_VERSION,
    )
