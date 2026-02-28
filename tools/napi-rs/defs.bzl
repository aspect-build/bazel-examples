load("@rules_rust//rust:defs.bzl", "rust_shared_library")
load("@bazel_skylib//rules:select_file.bzl", "select_file")
load("@aspect_rules_js//js:defs.bzl", "js_run_binary")
load("@bazel_lib//lib:copy_file.bzl", "copy_file")

TMP_FOLDER_NAME = "napi_type_def_tmp"

def napi_rust_shared_library(name, deps, **kwargs):
  """Create a NAPI-RS Rust shared library and generate the NAPI type definitions and typegen binary.

  Args:
    name: The name of the target.
    deps: The dependencies for the Rust library. The nodejs headers are added automatically.
    **kwargs: Additional arguments for the rust_shared_library rule.
  """
  lib_target = "_{}_rust_shared_library".format(name)
  bindings_target = "_{}_napi_type_defs".format(name)
  types_target = "_{}_typegen".format(name)
  types_file = "{}.d.ts".format(name)
  rust_shared_library(
      name = lib_target,
      extra_outdirs = [TMP_FOLDER_NAME],
      rustc_env = {
          "NAPI_TYPE_DEF_TMP_FOLDER": "$(BINDIR)/{}/{}".format(native.package_name(), TMP_FOLDER_NAME),
      },
      rustc_flags = select({
          "@platforms//os:macos": [
              "--codegen=link-arg=-undefined",
              "--codegen=link-arg=dynamic_lookup",
          ],
          "//conditions:default": [],
      }),
      deps = deps + [
          "@rules_nodejs//nodejs/headers:current_node_cc_headers",
      ],
      **kwargs,
  )

  select_file(
      name = bindings_target,
      srcs = lib_target,
      subpath = TMP_FOLDER_NAME,
      visibility = ["//visibility:public"],
  )

  select_file(
    name = "{}_select_rust_binding".format(name),
    srcs = lib_target,
    # FIXME: hardcoded
    subpath = "lib{}.dylib".format(lib_target),
    visibility = ["//visibility:public"],
  )

  js_run_binary(
      name = types_target,
      srcs = [bindings_target],
      tool = Label("//tools/napi-rs:typegen_bin"),
      args = [
          "$(rootpath {})".format(bindings_target),
          "$(rootpath {})".format(types_file),
      ],
      tags = [
          # TODO(alexeagle): continue the struggle against it finding no bindings in the sandbox
          "local",
      ],
      outs = [types_file],
  )

  # Need to rename the files from .so/.dylib to .node for Node.js
  copy_file(
        name = "{}_copy_rust_binding".format(name),
        src = "{}_select_rust_binding".format(name),
        out = "{}.node".format(name),
  )


  # Final production is a pair of .node rust binding and .d.ts type definitions.
  native.filegroup(
    name = name,
    srcs = [
        "{}_copy_rust_binding".format(name),
        types_target,
    ],
  )
