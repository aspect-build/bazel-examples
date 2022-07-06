def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path.replace(".ts", ".js")

# Generate a karma.config.js file to:
# - run the given bundle containing specs
# - serve the given assets via http
# - bootstrap a set of js files before the bundle
def _generate_karma_config_impl(ctx):
    configuration = ctx.outputs.configuration

    # root-relative (runfiles) path to the directory containing karma.conf
    config_segments = len(configuration.short_path.split("/"))

    # Extract the bundle directory out of the bundle target files
    bundle_dir = [f for f in ctx.attr.bundle[DefaultInfo].files.to_list() if f.is_directory][0]

    ctx.actions.expand_template(
        template = ctx.file._conf_tmpl,
        output = configuration,
        substitutions = {
            "TMPL_bootstrap_files": "\n  ".join(["'%s'," % _to_manifest_path(ctx, e) for e in ctx.files.bootstrap]),
            "TMPL_runfiles_path": "/".join([".."] * config_segments),
            "TMPL_static_files": "\n  ".join(["'%s'," % _to_manifest_path(ctx, e) for e in ctx.files.static_files]),
            # "TMPL_test_bundle_dir": _to_manifest_path(ctx, bundle_dir),
            "TMPL_test_bundle_dir": "\n  ".join(["'%s'," % _to_manifest_path(ctx, e) for e in ctx.files.bundle]),
        },
    )

generate_karma_config = rule(
    implementation = _generate_karma_config_impl,
    attrs = {
        # https://github.com/bazelbuild/rules_nodejs/blob/3.3.0/packages/concatjs/web_test/karma_web_test.bzl#L34-L39
        "bootstrap": attr.label_list(
            doc = """JavaScript files to load via <script> *before* the specs""",
            allow_files = [".js"],
        ),
        "bundle": attr.label(
            doc = """The label producing the bundle directory containing the specs""",
            mandatory = True,
        ),

        # https://github.com/bazelbuild/rules_nodejs/blob/3.3.0/packages/concatjs/web_test/karma_web_test.bzl#L81-L87
        "static_files": attr.label_list(
            doc = """Arbitrary files which are available to be served on request""",
            allow_files = True,
        ),

        # https://github.com/bazelbuild/rules_nodejs/blob/3.3.0/packages/concatjs/web_test/karma_web_test.bzl#L88-L91
        "_conf_tmpl": attr.label(
            doc = """the karma config template""",
            cfg = "exec",
            allow_single_file = True,
            default = Label("//:karma.conf.js"),
        ),
    },
    outputs = {
        "configuration": "%{name}.js",
    },
)
