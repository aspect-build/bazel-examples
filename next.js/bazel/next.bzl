load("@aspect_rules_js//js:defs.bzl", "js_binary", "js_run_binary", "js_run_devserver")

def next(
        name,
        srcs,
        data,
        next_bin,
        next_build_out = ".next",
        **kwargs):
    """Generates Next.js targets build, dev & start targets.

    `{name}`       - a js_run_binary build target that runs `next build`
    `{name}_dev`   - a js_run_devserver binary target that runs `next dev`
    `{name}_start` - a js_run_devserver binary target that runs `next start`

    Use this macro in the BUILD file at the root of a next app where the `next.config.js` file is
    located.

    For example, a target such as

    ```
    next(
        name = "next",
        srcs = [
            "//app/pages",
            "//app/public",
            "//app/styles",
        ],
        data = [
            ":node_modules/next",
            ":node_modules/react-dom",
            ":node_modules/react",
            ":package.json",
            "//:node_modules/typescript",
            "next.config.js",
        ],
        next_bin = "./node_modules/.bin/next",
    )
    ```

    in an `app/BUILD.bazel` file will create the targets:

    ```
    //app:next
    //app:next_dev
    //app:next_start
    ```

    To build the above next app, equivalent to running
    `next build` outside Bazel, run,

    ```
    bazel build //app:next
    ```

    To run the development server in watch mode with
    [ibazel](https://github.com/bazelbuild/bazel-watcher), equivalent to running
    `next dev` outside Bazel, run

    ```
    ibazel run //app:next_dev
    ```

    To run the production server in watch mode with
    [ibazel](https://github.com/bazelbuild/bazel-watcher), equivalent to running
    `next start` outside Bazel,

    ```
    ibazel run //app:next_start
    ```

    TODO: add lint target

    Args:
        name: The name of the build target.

        srcs: Source files to include in build & dev targets.
            Typically these are source files or transpiled source files in Next.js source folders
            such as `pages`, `public` & `styles`.

        data: Data files to include in all targets.
            These are typically npm packages required for the build & configuration files such as
            package.json and next.config.js.

        next_bin: The next bin command.
            Typically the path to the next entry point from the current package. For example `./node_modules/.bin/next`,
            if next is linked to the current package, or `../node_modules/.bin/next`, if next is linked in the parent package.

        next_build_out: The next build output directory. Defaults to `.next` which is the Next.js default output directory.

        **kwargs: Other attributes passed to all targets such as `tags`.
    """

    # This custom next js_binary is needed since next is very sensitive to it being found in two
    # `node_modules` trees. With the generated next build rule loaded from
    # `@npm//:next/package_json.bzl`, next is found both in the binary's runfiles `node_modules` and in
    # the execroot `node_modules` tree. This breaks the build. The work-around is to use this
    # slim `js_binary` without any dependencies on any node_modules.
    # TODO: should be able to remove this slim binary entry point once a `command` attribute is added to js_run_binary.
    js_binary(
        name = "{}_slim_bin".format(name),
        entry_point = "//bazel:next_entry",
        env = {"NEXT_BIN": next_bin},
        **kwargs
    )

    # `next build` creates an optimized bundle of the application
    # https://nextjs.org/docs/api-reference/cli#build
    js_run_binary(
        name = name,
        tool = "{}_slim_bin".format(name),
        args = ["build"],
        srcs = srcs + data,
        outs = [next_build_out],
        chdir = native.package_name(),
        **kwargs
    )

    # `next dev` runs the application in development mode
    # https://nextjs.org/docs/api-reference/cli#development
    js_run_devserver(
        name = "{}_dev".format(name),
        command = next_bin,
        args = ["dev"],
        data = srcs + data,
        chdir = native.package_name(),
        **kwargs
    )

    # `next start` runs the application in production mode
    # https://nextjs.org/docs/api-reference/cli#production
    js_run_devserver(
        name = "{}_start".format(name),
        command = next_bin,
        args = ["start"],
        data = data + [":{}".format(name)],
        chdir = native.package_name(),
        **kwargs
    )
