"Illustrates how a reusable high-level workflow can be assembled from individual tools"

# load("@npm//@babel/cli:index.bzl", "bin")
# load("@npm//@bazel/rollup:index.bzl", "rollup_bundle")
# load("@npm_deps//@bazel/terser:index.bzl", "terser_minified")
# load("@npm_deps//@bazel/typescript:index.bzl", "ts_project")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@aspect_rules_rollup//rollup:rollup_bundle.bzl", "rollup_bundle")

def differential_loading(name, entry_point, srcs):
    "Common workflow to serve TypeScript to modern browsers"

    ts_project(
        name = name + "_lib",
        srcs = srcs,
    )

    rollup_bundle(
        name = name + "_chunks",
        deps = [name + "_lib"],
        sourcemap = "inline",
        config_file = "//:rollup.config.js",
        entry_points = {
            entry_point: "index",
        },
        output_dir = True,
    )

    # # For older browsers, we'll transform the output chunks to es5 + systemjs loader
    # babel(
    #     name = name + "_chunks_es5",
    #     data = [
    #         name + "_chunks",
    #         "es5.babelrc",
    #         "@npm_deps//@babel/preset-env",
    #     ],
    #     output_dir = True,
    #     args = [
    #         "$(execpath %s_chunks)" % name,
    #         "--config-file",
    #         "./$(execpath es5.babelrc)",
    #         "--out-dir",
    #         "$(@D)",
    #     ],
    # )

    # # Run terser against both modern and legacy browser chunks
    # terser_minified(
    #     name = name + "_chunks_es5.min",
    #     src = name + "_chunks_es5",
    # )

    # terser_minified(
    #     name = name + "_chunks.min",
    #     src = name + "_chunks",
    # )

    # pkg_web(
    #     name = name,
    #     srcs = [
    #         "index.html",
    #         "favicon.png",
    #         name + "_chunks.min",
    #         name + "_chunks_es5.min",
    #     ],
    # )
