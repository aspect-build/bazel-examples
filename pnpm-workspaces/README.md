# pnpm-workspaces

This example aims to showcase a minimal pnpm [workspace](https://pnpm.io/workspaces).

It uses the Bazel rules [`rules_js`](https://github.com/aspect-build/rules_js) and [`rules_ts`](https://github.com/aspect-build/rules_ts).

It contains two main apps [`alpha`](#alpha) and [`beta`](#beta) and four internal libraries [`one`](#one), [`two`](#two), [`shared`](#shared), and [`first`](#first).

None of the apps or libraries are published to NPM, hence a lot of information related to that (specifically in package.json) has been omitted.

## general

The root of the workspace contains two files of note: [`pnpm-workspace.yaml`](#pnpm-workspaceyaml) and [`package.json`](#packagejson)

### pnpm-workspace.yaml

Is where the projects (apps and libraries) are enumerated. In this example we use globbing to tell pnpm that all projects under `apps` and `packages` belong to the workspace.

### package.json

Default location for all dependencies. Each project has the option to override a dependency defined in the root [package.json](package.json). See the [package.json](apps/alpha/package.json) in `alpha` for an example of this.

## alpha

A Typescript app that is dependent on the internal libraries [`one`](#one) and [`shared`](#shared).

It's also dependent on the external dependencies `star-wars-quotes` and `inspirational-quotes`.

In the case of `inspirational-quotes`, it overrides the version defined in the root [`package.json`](package.json).

This also means that we have to add the `npm_link_all_packages` function in the [`BUILD`](apps/alpha/BUILD.bazel) file.

## beta

A Javascript app that is dependent on the internal libraries [`two`](#two) and [`shared`](#shared).

It's also dependent on the external dependencies `trek-quotes` and `inspirational-quotes`.

Things of note are:

- there is no `package.json`
- it has two indirect dependencies via [`two`](#two)

## one

A Typescript library that is consumed by [`alpha`](#alpha).

It has no dependencies.

## two

A Javascript library that is consumed by [`beta`](#beta).

It has two dependencies: `cowsay` that is an external dependency and [`first`](#first) that is an internal dependency.

**Note** that these dependencies has to be enumerated in the `data` argument to the `npm_package` function in [BUILD.bazel](packages/two/BUILD.bazel).

## shared

A Typescript library that is consumed by both [`alpha`](#alpha) and [`beta`](#beta).

It has no dependencies.

## first

A Javascript library that is consumed by [`two`](#two).

It has no dependencies.
