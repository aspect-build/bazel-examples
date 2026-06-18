# Aspect Bazel Examples

This variety of examples demonstrate how a large polyglot monorepo is configured with [Bazel](https://bazel.build).
It's intended for Developer Infrastructure and Build systems experts to study solutions to problems at scale.

- Hoping to learn Advanced Bazel concepts? Our [Bazel 200-series courses](https://training.aspect.build) use this repository as the example material.
- Just looking for a smaller Bazel repo as a playground? Run `aspect init` to scaffold a new project with the languages and features you care about — see [aspect init and the Aspect Starters](https://aspect.build/blog/aspect-init-and-starters), or the [getting started guide](https://aspect.build/docs/guides/getting-started/).

See all our other Bazel material on our GitHub: <https://github.com/aspect-build>

## Aspect CLI

This repository uses the [Aspect CLI](https://aspect.build/docs/cli/overview) for an improved developer experience, both for local development and on CI. `bazel` is a build system, not a developer-workflow tool — the Aspect CLI (`aspect`) is a free, open-source task runner that *extends* Bazel with first-class workflows (`lint`, `format`, `gazelle`, `delivery`) alongside enhanced `build`, `test`, and `run`. Your existing `bazel` commands keep working unchanged; `aspect` adds a programmable task-runner layer on top.

- **Install:** <https://aspect.build/docs/cli/install>
- **Overview & tasks:** <https://aspect.build/docs/cli/overview>

This repo ships the [`tools/bazel` wrapper](https://aspect.build/docs/cli/install#keep-your-team-typing-bazel-with-the-tools%2Fbazel-wrapper), so you can keep typing `bazel` and Bazelisk routes each command to the right tool: `bazel build`, `bazel test`, `bazel lint`, `bazel format`, `bazel gazelle`, etc. all go through `aspect`, while `bazel query`/`info`/etc. run vanilla `bazel`. The `aspect <task>` and `bazel <task>` forms are interchangeable here; this README uses `aspect <task>` for clarity about which tool runs.

### Commands provided by the Aspect CLI

These tasks are *not* part of the Bazel CLI provided by Google:

| Command | What it does |
| --- | --- |
| [`aspect gazelle`](https://aspect.build/docs/cli/tasks/gazelle) | Generate and update `BUILD` files from your source. Runs `//tools/gazelle:gazelle`. |
| [`aspect lint`](https://aspect.build/docs/cli/tasks/lint) | Run linters ([rules_lint](https://github.com/aspect-build/rules_lint) aspects) with colored output and interactive fix suggestions. |
| [`aspect format`](https://aspect.build/docs/cli/tasks/format) | Format source files. Runs `//tools/format:format`. |
| [`aspect buildifier`](https://aspect.build/docs/cli/tasks/buildifier) | Format Starlark (`BUILD`, `MODULE.bazel`, `.bzl`, `.axl`) with buildifier. |
| [`aspect delivery`](https://aspect.build/docs/cli/tasks/delivery) | Build and deliver release artifacts (e.g. OCI images), once per commit. |

### Commands that also exist on Bazel

These work like the `bazel` commands of the same name, with extra developer-experience niceties (better output, change detection, CI annotations):

| Command | What it does |
| --- | --- |
| [`aspect build`](https://aspect.build/docs/cli/tasks/build_test) | Build targets. |
| [`aspect test`](https://aspect.build/docs/cli/tasks/build_test) | Run tests. |
| `aspect run` | Build a target and run the resulting binary. |

## Developer workflows

The sections below cover the common day-to-day tasks in this monorepo.

### Formatting code

- Run `aspect format` to re-format all changed files locally.
- Run `aspect format path/to/file` to re-format a single file.
- Run `pre-commit install` to auto-format changed files on `git commit`; see https://pre-commit.com/.

Without the Aspect CLI, run the underlying formatter target directly with `bazel run //tools/format` (or `bazel run //tools/format path/to/file` for a single file).

### Linting code

We use [rules_lint](https://github.com/aspect-build/rules_lint) to run linting tools using Bazel's aspects feature.
Linters produce report files, which are cached like any other Bazel actions.

Run `aspect lint //...` to check for lint violations. The [`aspect lint`](https://aspect.build/docs/cli/tasks/lint) task collects the report files, presents them with nice colored boundaries, gives you interactive suggestions to apply fixes, produces a matching exit code, and more.

See comments on https://github.com/aspect-build/bazel-examples/pull/335 for some examples of how to exercise the linters.

> [!NOTE]
> `aspect lint` wraps rules_lint's aspects. If you can't use the Aspect CLI, you can apply the aspect by hand with vanilla Bazel — e.g. `bazel build --aspects=//tools/lint:linters.bzl%eslint --output_groups=rules_lint_human //...` — then read the per-target `*AspectRulesLint*` report from `bazel-bin`. rules_lint ships a [sample shell script](https://github.com/aspect-build/rules_lint/blob/main/example/lint.sh) that wraps this. The CLI exists so you don't have to.

### Installing dev tools

For developers to be able to run a CLI tool without needing manual installation:

1. Add the tool to `tools/tools.lock.json` and `tools/BUILD.bazel`
2. Run `bazel run //tools:bazel_env` (following any instructions it prints)
3. When working within the workspace, tools will be available on the PATH

To update the versions of installed tools, run:

```shell
% cd $(bazel info workspace)/tools; ./multitool --lockfile tools.lock.json update
```

See https://blog.aspect.build/run-tools-installed-by-bazel for details.

### Working with npm packages

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

### Working with Python packages

After adding a new `import` statement in Python code, run `aspect gazelle` to update the BUILD file.

If the package is not already a dependency of the project, you'll have to do some additional steps:

```shell
# Update dependencies table to include your new dependency
% vim pyproject.toml
# Update lock files to pin this dependency
% bazel run //requirements:runtime.update
% bazel run //requirements:requirements.all.update
% bazel run //requirements:gazelle_python_manifest.update
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

### Working with Go modules

After adding a new `import` statement in Go code, run `aspect gazelle` to update the BUILD file.

If the package is not already a dependency of the project, you'll have to do some additional steps.
Run these commands from the workspace root:

```shell
# Update go.mod and go.sum, using same Go SDK as Bazel
% $(bazel info workspace)/tools/go mod tidy -v
# Update MODULE.bazel to include the package in `use_repo`
% bazel mod tidy
# Repeat
% aspect gazelle
```

### Working with Java maven dependencies

Maven coordinates for third-party packages live in the `MODULE.bazel` file.

After changing them, run `bazel run @unpinned_maven//:pin` to update the `maven_install.json` file.
This file is used by `rules_jvm_external` to fetch packages.

Then use the `artifact("some.org:coordinate")` helper to resolve a label to the resulting `java_library` targets.

### Stamping release builds

Stamping produces non-deterministic outputs by including information such as a version number or commit hash.

Read more: https://blog.aspect.build/stamping-bazel-builds-with-selective-delivery

To declare a build output which can be stamped, use a rule that is stamp-aware such as expand_template.

Available keys are listed in `/tools/workspace_status.sh` and may include:

- `STABLE_GIT_COMMIT`: the commit hash of the HEAD (current) commit
- `STABLE_MONOREPO_VERSION`: a semver-compatible version in the form `2020.44.123+abc1234`

To request stamped build outputs, add the flag `--config=release`.
