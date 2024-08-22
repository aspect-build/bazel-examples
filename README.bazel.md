# Bazel workflows

This repository uses Bazel to provide a monorepo developer experience.

## Formatting code

- Run `bazel run format` to re-format all files locally.
- Run `bazel run format path/to/file` to re-format a single file.
- Run `pre-commit install` to auto-format changed files on `git commit`; see https://pre-commit.com/.

## Linting code

- Run `bazel lint //...` or any other target pattern to check for lint violations.

## Installing dev tools

For developers to be able to run a CLI tool without needing manual installation:

1. Add the tool to `tools/tools.lock.json`
2. `cd tools; ln -s _multitool_run_under_cwd.sh name_of_tool`
3. Instruct developers to run `./tools/name_of_tool` rather than install that tool on their machine.

See https://blog.aspect.build/run-tools-installed-by-bazel for details.

## Working with npm packages

To install a `node_modules` tree locally for the editor or other tooling outside of Bazel:

```
bazel run -- @pnpm --dir $PWD install
```

Similarly, you can run other `pnpm` commands to install or remove packages.
This ensures you use the same pnpm version as other developers, and the lockfile format will stay constant.

## Working with Python packages

After adding a new `import` statement in Python code, run `bazel configure` to update the BUILD file.

If the package is not already a dependency of the project, you'll have to do some additional steps:

```shell
# Update dependencies table to include your new dependency
% vim pyproject.toml
# Update lock files to pin this dependency
% bazel run //requirements:runtime.update
% bazel run //requirements:requirements.all.update
% bazel run //:gazelle_python_manifest.update
```

To create a runnable binary for a console script from a third-party package, run the following:

```shell
% cat<<'EOF' | ./tools/buildozer -f -
new_load @rules_python//python/entry_points:py_console_script_binary.bzl py_console_script_binary|new py_console_script_binary scriptname|tools:__pkg__
set pkg "@pip//package_name_snake_case"|tools:scriptname
EOF
```

Then edit the new entry in `tools/BUILD` to replace `package_name_snake_case` with the name of the package that exports a console script, and `scriptname` with the name of the script.

>[!NOTE]
>See https://rules-python.readthedocs.io/en/stable/api/python/entry_points/py_console_script_binary.html for more details.

## Working with Go modules

After adding a new `import` statement in Go code, run `bazel configure` to update the BUILD file.

If the package is not already a dependency of the project, you'll have to do some additional steps:

```shell
# Update go.mod and go.sum, using same Go SDK as Bazel
% bazel run @rules_go//go -- mod tidy -v
# Update MODULE.bazel to include the package in `use_repo`
% bazel mod tidy
# Repeat
% bazel configure
```

## Stamping release builds

Stamping produces non-deterministic outputs by including information such as a version number or commit hash.

Read more: https://blog.aspect.build/stamping-bazel-builds-with-selective-delivery

To declare a build output which can be stamped, use a rule that is stamp-aware such as
[expand_template](https://docs.aspect.build/rulesets/aspect_bazel_lib/docs/expand_template).

Available keys are listed in `/tools/workspace_status.sh` and may include:

- `STABLE_GIT_COMMIT`: the commit hash of the HEAD (current) commit
- `STABLE_MONOREPO_VERSION`: a semver-compatible version in the form `2020.44.123+abc1234`

To request stamped build outputs, add the flag `--config=release`.
