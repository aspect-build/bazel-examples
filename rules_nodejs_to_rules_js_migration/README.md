# Example of migrating from rules_nodejs to rules_js

In general, it is hard to cover all the different possible ways that a rules_nodejs repository is
organized to show how to migrate to rules_js for all cases. Migrations in large repositories are
generally done piecemeal so for some time you have both rules_js and rules_nodejs in your
repository.

## Migration contraints

### Versions

This example uses rules_nodejs 4.7.1 but it should also with rules_nodejs 5.x.x. It is recommended
to migrate to the latest version of rules_js and rules_ts.

### npm repository rules

The constraint that can make a piecewise migrating from rules_nodejs to rules_js most challenging is
how to managed npm dependencies in both rule sets at the same time in the build.

In short, node_modules trees cannot be linked to the same place from both rule sets. In other words,
if rules_nodejs has a node_modules tree at the root of the WORKSPACE in your current build, you
cannot also link a rules_js node_modules tree there. The two trees would conflict at runtime time
and things will fail to build in unexpected ways.

In this example, the rules_nodejs package.json and node_modules tree is found at the root of the
repository.

In a repository where there is only a single package.json and all source are under a common
sub-directory such as `/src` you could link the rules_js `node_modules` to `/src/node_modules` and
all targets would resolve npm dependencies in both rules_js and rules_nodejs without any more
complication.

In this repository, however, we need targets under both `/libs` and `/packages` to resolve npm deps
in rules_js and we can't occupy the root of the workspace for a rule_js `node_modules` tree so the
pattern we used to create a pnpm workspace rooted in the `/bazel` and as we migrate individual packages
to Bazel we add those to the pnpm workspace so that the rules_js targets in those packages can
resolve node_modules dependencies.

To keep dependency versions in sync between the root rules_nodejs package.json and the pnpm workspaces
package.json files, we setup a root `//:syncpack_test` target that checks that all dependency versions
are aligned throughout the repository.

### pnpm

rules_js works best with pnpm and it is recommended to use pnpm outside of Bazel to generate the
pnpm-lock file. You can also alternately use yarn and rules_js will generate the pnpm lock file from
the yarn lock file under the hood although this approach is not recommended and it does not yet work
with pnpm workspaces so practically only applicable to a migration that has a single package.json
for both rules_nodejs and rules_js.

## Example structure

### libs

There are 3 "libraries" under `/libs`. Imports between libraries are relative and the libraries are
not linked to node_modules in either rules_nodejs or rules_js.

- `libs/a` is built with rules_nodejs
- `libs/b` is built with rules_js and depends on the `//libs/a:a_rjs` adapter target.
- `libs/c` is built with rules_nodejs and depends on `//libs/b` adapter target.

### packages

Similarly there are 3 "packages" under `/packages`. Imports between these packages using their package names
via node_modules links.

- `packages/a` is built with rules_nodejs
- `packages/b` is built with rules_js and depends on the `//libs/a`.
- `packages/c` is built with rules_nodejs and depends on `//libs/b`

## Bazel ts_project macros

Wrapper macros for rules_js and rules_nodejs `ts_project` are found under
`//bazel/rules_js:defs.bzl` and `//bazel/rules_nodejs:defs.bzl`.

## Bazel adapter rules
There are example two "adapter" rules in this repository for the `libs` case where interop between
rules_js and rules_nodejs is not through linked node_modules packages:

- `rules_nodejs_to_rules_js_adapter` adapts a rules_nodejs target so that it can be used as a
dependency in a rules_js target.

- `rules_js_to_rules_nodejs_adapter` adapts a rules_js target so that it can be used as a
dependency in a rules_nodejs target.
