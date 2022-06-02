"wrapper around ts_project which sets defaults"
load("@aspect_rules_swc//swc:defs.bzl", "swc_transpiler")
load("@aspect_rules_ts//ts:defs.bzl", _ts_project = "ts_project")

def ts_project(name, visibility = ["//:__subpackages__"], **kwargs):
    _ts_project(
        name = name,
        allow_js = True,
        declaration = True,
        incremental = True,
        preserve_jsx = True,
        resolve_json_module = True,
        tsconfig = "//:tsconfig",
        transpiler = swc_transpiler,
        visibility = visibility,
        **kwargs
    )
