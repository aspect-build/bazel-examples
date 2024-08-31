# Bazel workflows

This repository uses Bazel to provide a monorepo developer experience.

## Formatting code

- Run `bazel run format` to re-format all files locally.
- Run `bazel run format path/to/file` to re-format a single file.
- Run `pre-commit install` to auto-format changed files on `git commit`; see https://pre-commit.com/.

## Linting code

We use [rules_lint](https://github.com/aspect-build/rules_lint) to run linting tools using Bazel's aspects feature.
Linters produce report files, which are cached like any other Bazel actions.
Printing the report files to the terminal can be done in a couple ways, as follows.

### With Aspect CLI

The [`lint` command](https://docs.aspect.build/cli/commands/aspect_lint) is provided by Aspect CLI but is *not* part of the Bazel CLI provided by Google.
It collects the correct report files, presents them with nice colored boundaries, gives you interactive suggestions to apply fixes, produces a matching exit code, and more.

- Run `bazel lint //...` to check for lint violations.

See comments on https://github.com/aspect-build/bazel-examples/pull/335 for some examples of how to exercise the linters.

### With vanilla Bazel

Aspect CLI makes the developer experience for linting a lot nicer, but it's not required.

1. Run `bazel build --config=lint //...` to produce lint reports.
  (See the `build:lint` lines in `.bazelrc` for the flags this config option expands to.)
1. Print the resulting reports, for example a simplistic one-liner using `find` looks like:
  `find $(bazel info bazel-bin) -name "*AspectRulesLint*report" -exec cat {} \; `

For a more robust developer experience, see the [sample shell script](https://github.com/aspect-build/rules_lint/blob/main/example/lint.sh) in the rules_lint example.

## Installing dev tools

For developers to be able to run a CLI tool without needing manual installation:

1. Add the tool to `tools/tools.lock.json`
2. `cd tools; ln -s _run_under_cwd.sh name_of_tool`
3. Instruct developers to run `./tools/name_of_tool` rather than install that tool on their machine.

To update the versions of installed tools, run:

```shell
% cd $(bazel info workspace)/tools; ./multitool --lockfile tools.lock.json update
```

See https://blog.aspect.build/run-tools-installed-by-bazel for details.

## Working with npm packages

To install a `node_modules` tree locally for the editor or other tooling outside of Bazel,
run this command from any folder with a `package.json` file:

```shell
% $(bazel info workspace)/tools/pnpm install
```

> NB: `bazel info workspace` avoids having a bunch of `../` segments when running tools from a subdirectory.

Similarly, you can run other `pnpm` commands to add or remove packages.

```shell
% $(bazel info workspace)/tools/pnpm add http-server
```

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

If the package is not already a dependency of the project, you'll have to do some additional steps.
Run these commands from the workspace root:

```shell
# Update go.mod and go.sum, using same Go SDK as Bazel
% ./tools/go mod tidy -v
# Update MODULE.bazel to include the package in `use_repo`
% bazel mod tidy
# Repeat
% bazel configure
```

## Working with Java maven dependencies

Maven coordinates for third-party packages live in the `MODULE.bazel` file.

After changing them, run `bazel run @unpinned_maven//:pin` to update the `maven_install.json` file.
This file is used by `rules_jvm_external` to fetch packages.

Then use the `artifact("some.org:coordinate")` helper to resolve a label to the resulting `java_library` targets.

## Stamping release builds

Stamping produces non-deterministic outputs by including information such as a version number or commit hash.

Read more: https://blog.aspect.build/stamping-bazel-builds-with-selective-delivery

To declare a build output which can be stamped, use a rule that is stamp-aware such as
[expand_template](https://docs.aspect.build/rulesets/aspect_bazel_lib/docs/expand_template).

Available keys are listed in `/tools/workspace_status.sh` and may include:

- `STABLE_GIT_COMMIT`: the commit hash of the HEAD (current) commit
- `STABLE_MONOREPO_VERSION`: a semver-compatible version in the form `2020.44.123+abc1234`

To request stamped build outputs, add the flag `--config=release`.
