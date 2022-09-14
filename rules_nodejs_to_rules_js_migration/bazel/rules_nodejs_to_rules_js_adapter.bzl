load("@aspect_rules_js//js:defs.bzl", _js_library = "js_library")
load(
    "@build_bazel_rules_nodejs//:providers.bzl",
    "DeclarationInfo",
    "ExternalNpmPackageInfo",
    "JSModuleInfo",
)

_ATTRS = {
    "deps": attr.label_list(),
}

def _impl(ctx):
    files_depsets = []

    for dep in ctx.attr.deps:
        if ExternalNpmPackageInfo in dep:
            continue
        if JSModuleInfo in dep:
            files_depsets.append(dep[JSModuleInfo].sources)
        if DeclarationInfo in dep:
            files_depsets.append(dep[DeclarationInfo].transitive_declarations)

    files = []
    for file in depset(transitive = files_depsets).to_list():
        if "node_modules/" in file.path:
            continue
        files.append(file)

    return [
        DefaultInfo(files = depset(files)),
    ]

_rules_nodejs_to_rules_js_adapter = rule(
    implementation = _impl,
    attrs = _ATTRS,
)

def rules_nodejs_to_rules_js_adapter(name, deps, **kwargs):
    adapter_target = "{}_adapter".format(name)
    _rules_nodejs_to_rules_js_adapter(
        name = adapter_target,
        deps = deps,
    )
    _js_library(
        name = name,
        srcs = [adapter_target],
        **kwargs
    )
