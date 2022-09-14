load("@aspect_rules_js//js:providers.bzl", "JsInfo")
load("@build_bazel_rules_nodejs//:index.bzl", _js_library = "js_library")

_ATTRS = {
    "deps": attr.label_list(),
}

def _impl(ctx):
    files_depsets = []

    for dep in ctx.attr.deps:
        if JsInfo in dep:
            files_depsets.append(dep[JsInfo].transitive_sources)
            files_depsets.append(dep[JsInfo].transitive_declarations)

    files = []
    for file in depset(transitive = files_depsets).to_list():
        if "node_modules/" in file.path:
            continue
        files.append(file)

    return [
        DefaultInfo(files = depset(files)),
    ]

_rules_js_to_rules_nodejs_adapter = rule(
    implementation = _impl,
    attrs = _ATTRS,
)

def rules_js_to_rules_nodejs_adapter(name, deps, transitive_deps = [], **kwargs):
    adapter_target = "{}_adapter".format(name)
    _rules_js_to_rules_nodejs_adapter(
        name = adapter_target,
        deps = deps,
    )
    _js_library(
        name = name,
        srcs = [adapter_target],
        deps = transitive_deps,
        **kwargs
    )
