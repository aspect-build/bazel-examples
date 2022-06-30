load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

def to_manifest_path(ctx, file):
    if file.basename.startswith("../"):
        return file.basename[3:]
    else:
        return file.basename.replace(".ts", ".js")

# Generate a karma.config.js file to:
# - run the given bundle containing specs
# - bootstrap a set of js files before the bundle
def _generate_karma_config_impl(ctx):
    configuration = ctx.outputs.configuration

    # root-relative (runfiles) path to the directory containing karma.conf
    config_segments = len(configuration.short_path.split("/"))

    ctx.actions.expand_template(
        template = ctx.file._conf_tmpl,
        output = configuration,
        substitutions = {
            "TMPL_bootstrap_files": "\n  ".join(["'%s'," % to_manifest_path(ctx, e) for e in ctx.files.bootstrap_bundles]),
            "TMPL_runfiles_path": "/".join([".."] * config_segments),
            "TMPL_spec_files": "\n  ".join(["'%s'," % to_manifest_path(ctx, e) for e in ctx.files.test_bundles]),
        },
    )

generate_karma_config = rule(
    implementation = _generate_karma_config_impl,
    attrs = {
        # https://github.com/bazelbuild/rules_nodejs/blob/3.3.0/packages/concatjs/web_test/karma_web_test.bzl#L34-L39
        "bootstrap_bundles": attr.label_list(
            doc = """JavaScript files to load via <script> *before* the specs""",
            allow_files = [".js"],
        ),
        "test_bundles": attr.label_list(
            doc = """The label producing the bundle directory containing the specs""",
        ),

        # https://github.com/bazelbuild/rules_nodejs/blob/3.3.0/packages/concatjs/web_test/karma_web_test.bzl#L88-L91
        "_conf_tmpl": attr.label(
            doc = """the karma config template""",
            cfg = "exec",
            allow_single_file = True,
            default = Label("//tools:karma.conf.js"),
        ),
    },
    outputs = {
        "configuration": "%{name}.cjs",
    },
)

def generate_test_bootstrap(name):
    copy_file(
        name = name,
        src = "//tools:test_bootstrap",
        out = "test_bootstrap.js",
        testonly = 1,
    )

def generate_test_setup(name):
    copy_file(
        name = name,
        out = "%s.ts" % name,
        testonly = 1,
        src = "//tools:test-setup.ts",
    )
