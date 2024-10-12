"""
@aspect_rules_ts macros to enable custom config, transpiler.
"""

load("@aspect_rules_ts//ts:defs.bzl", _ts_project = "ts_project")
load("@aspect_rules_swc//swc:defs.bzl", "swc")
load("@bazel_skylib//lib:partial.bzl", "partial")

def ts_project(name, **kwargs):
    _ts_project(
        name = name,
        declaration = kwargs.pop("declaration", True),
        transpiler = partial.make(
            swc,
            swcrc = "//:.swcrc",
        ),
        tsconfig = kwargs.pop("tsconfig", "//:tsconfig"),
        **kwargs
    )
