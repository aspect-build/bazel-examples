# Example of migrating an existing Bazel project to rules_js

This example illustrates some of the techniques you may need to migrate to rules_js.
It accompanies the [migration guide](https://github.com/aspect-build/rules_js/blob/main/docs/migrate.md).
We assume you're replacing the `build_bazel_rules_nodejs` module, which contains most of the code from
https://github.com/bazelbuild/rules_nodejs that is now unmaintained.

In general, it is hard to cover all the different possible ways that a repository is
organized with build_bazel_rules_nodejs
to show how to migrate to rules_js for all cases. Migrations in large repositories are
generally done piecemeal so for some time you have both rules_js and build_bazel_rules_nodejs in your
repository.

If you feel that more illustration would help you migrate, please file an issue, and if possible
consider adding a [bug bounty](https://opencollective.com/aspect-build/projects/rules_js) since the
maintainers' volunteer time is very limited.

## Migration contraints

### Versions

This example uses build_bazel_rules_nodejs 4.7.1 but it should also work with build_bazel_rules_nodejs 5.x.x.
We demonstrate with 4.7.1 to show an important point: it's not necessary to have build_bazel_rules_nodejs
updated to the latest version before migrating.
In fact, that migration can be a fair amount of work as well, which is largely sunk cost when you migrate to rules_js.

It is recommended to migrate to the latest version of rules_js and rules_ts.

### npm repository rules

The constraint that can make a piecewise migrating from build_bazel_rules_nodejs to rules_js most challenging is
how to manage npm dependencies in both rule sets at the same time in the build.

In short, node_modules trees cannot be linked to the same place from both rule sets. In other words,
if build_bazel_rules_nodejs has a node_modules tree at the root of the WORKSPACE in your current build, you
cannot also link a rules_js node_modules tree there. The two trees would conflict at runtime time
and things will fail to build in unexpected ways.

In this example, the build_bazel_rules_nodejs-managed `package.json` and `node_modules` tree is found at the root of the
repository, as this reduces the effort to make your first rules_js target work.

In a repository where there is only a single `package.json` and all source are under a common
sub-directory such as `/src` you could link the rules_js `node_modules` to `/src/node_modules` and
all targets would resolve npm dependencies in both rules_js and build_bazel_rules_nodejs without any more
complication.

In this example, however, we need targets under both `/libs` and `/packages` to resolve npm deps in
rules_js and we can't occupy the root of the workspace for a rule_js `node_modules` tree.  The
pattern we used to work around this constraints is create a pnpm workspace rooted in the `/bazel`.
As individual packages/libs are migrated to Bazel, we add those to the pnpm workspace so that the
rules_js targets in those packages can resolve node_modules dependencies.

To keep dependency versions in sync between the root build_bazel_rules_nodejs `package.json` and the
pnpm workspaces `package.json` files, we setup a root `//:syncpack_test` target that checks that all
dependency versions are aligned throughout the repository.

### pnpm

rules_js works best with pnpm and it is recommended to use pnpm outside of Bazel to generate the
pnpm-lock file. You can also alternately use yarn or npm and rules_js will generate the pnpm lock file from
the yarn/npm lock file under the hood, although this approach is not recommended and it does not yet work
with pnpm workspaces so practically only applicable to a migration that has a single package.json
for both build_bazel_rules_nodejs and rules_js.

## Example structure

### libs

There are 3 "libraries" under `/libs`. Imports between libraries are relative and the libraries are
not linked to node_modules in either build_bazel_rules_nodejs or rules_js.

- `libs/a` is built with build_bazel_rules_nodejs
- `libs/b` is built with rules_js and depends on the `//libs/a:a_rjs` adapter target.
- `libs/c` is built with build_bazel_rules_nodejs and depends on `//libs/b` adapter target.

### packages

Similarly there are 3 "packages" under `/packages`. Imports between these packages using their package names
via node_modules links.

- `packages/a` is built with build_bazel_rules_nodejs
- `packages/b` is built with rules_js and depends on the `//libs/a`.
- `packages/c` is built with build_bazel_rules_nodejs and depends on `//libs/b`

## Bazel ts_project macros

Wrapper macros for rules_js `ts_project` and `@bazel/typescript#ts_project` are found under
`//bazel/rules_js:defs.bzl` and `//bazel/rules_nodejs:defs.bzl` respectively.

## Bazel adapter rules
There are twp example "adapter" rules in this repository for the `libs` case where interop between
rules_js and build_bazel_rules_nodejs is not through linked node_modules packages:

- `rules_nodejs_to_rules_js_adapter` adapts a build_bazel_rules_nodejs target so that it can be used as a
dependency in a rules_js target.

- `rules_js_to_rules_nodejs_adapter` adapts a rules_js target so that it can be used as a
dependency in a build_bazel_rules_nodejs target.
