"""Adapter from the Babel CLI to the ts_project#transpiler interface

See https://bazelbuild.github.io/rules_nodejs/TypeScript.html#ts_project-transpiler
"""
load("@npm//:@babel/cli/package_json.bzl", "bin")

def babel(name, srcs, js_outs, map_outs, **kwargs):
    # rules_js runs under the output tree in bazel-out/[arch]/bin
    execroot = "../../.."

    # In this example we compile each file individually.
    # You might instead use a single babel_cli call to compile
    # a directory of sources into an output directory,
    # but you'll need to:
    # - make sure the input directory only contains files listed in srcs
    # - make sure the js_outs are actually created in the expected path
    for idx, src in enumerate(srcs):
        # see https://babeljs.io/docs/en/babel-cli
        args = [
            "{}/$(location {})".format(execroot, src),
            "--presets=@babel/preset-typescript",
            "--out-file",
            "{}/$(location {})".format(execroot, js_outs[idx]),
        ]
        outs = [js_outs[idx]]

        if len(map_outs) > 0:
            args.append("--source-maps")
            outs.append(map_outs[idx])

        bin.babel(
            name = "{}_{}".format(name, idx),
            srcs = [
                src,
                "//:node_modules/@babel/preset-typescript",
            ],
            outs = outs,
            args = args,
            **kwargs
        )