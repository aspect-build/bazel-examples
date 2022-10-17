# pnpm-workspaces

This example aims to showcase a minimal pnpm [workspace](https://pnpm.io/workspaces).

It uses the Bazel rules [`rules_js`](https://github.com/aspect-build/rules_js) and [`rules_ts`](https://github.com/aspect-build/rules_ts).

It contains two main apps [`alpha`](#alpha) and [`beta`](#beta) and three internal libraries [`one`](#one), [`two`](#two), and [`shared`](#shared).

None of the apps or libraries are published to NPM, hence a lot of information related to that (specifically in package.json) has been omitted.

## general

The root of the workspace contains two files of note: [`pnpm-workspace.yaml`](#pnpm-workspaceyaml) and [`package.json`](#packagejson)

### pnpm-workspace.yaml

Is where the projects (apps and libraries) are enumerated. In this example we use globbing to tell pnpm that all projects under `apps` and `packages` belong to the workspace.

### package.json

Contains dependencies that will be shared by all projects. Each project then has a local package.json where project-specific dependencies are located.

## alpha

A Typescript app that is dependent on the internal libraries [`one`](#one) and [`shared`](#shared).

It's also dependent on the external dependencies `star-wars-quotes` and `inspirational-quotes`.

## beta

A Javascript app that is dependent on the internal libraries [`two`](#two) and [`shared`](#shared).

It's also dependent on the external dependencies `trek-quotes` and `inspirational-quotes`.

## one

A Typescript library that is consumed by [`alpha`](#alpha).

It has no dependencies.

## two

A Javascript library that is consumed by [`beta`](#beta).

It has no dependencies.

## shared

A Typescript library that is consumed by both [`alpha`](#alpha) and [`beta`](#beta).

It has no dependencies.
