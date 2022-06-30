# Angular

This project is an alternative to the basic [Angular example](../angular/) using the Angular compiler (ngc) directly without the use of the Angular CLI or Architect tools.

## Architect vs NGC

**Architect**: the basic [Angular example](../angular/) uses Architect (aka. Angular CLI Builders). This is the build tool inside of Angular CLI, so your existing application will continue to work the same way, and you can still get support from the Angular team. You can continue using the Angular CLI in addition to bazel. This may be the easiest to transition to from a non-bazel build, however will not provide the parallel and incremental advantages bazel is designed for.

**NGC**: the more idiomatic method is directly using the Angular `ngc` compiler along with other tools to create finer grained dependencies. The primary Angular / TypeScript code can be compiled using the [rules_ts](https://github.com/aspect-build/rules_ts) `ts_project` rule and its ability to replace the default `tsc` compiler with `ngc`. In addition to compiling the TypeScript code other processes such as compiling css (or sass, less etc), bundling, packaging, compiling tests, running tests etc. will all be independent bazel targets. Creating many finer grained targets allows bazel to orchestrate the execution, testing, caching and parallelization of each and every task.

## Angular NGC example

This example creates `ng_application` and `ng_pkg` macros to configure `ts_project` and other underlying rules for Angular. In addition to basic Angular configuration the macros take an extra step following common conventions for application and packages, this allows the macros to further simplify the BUILD files written by developers. For example:
* application and packages are assumed to depend on `@angular/core` and other common Angular packages (to avoid repeating such dependencies in each BUILD)
* packages have a `public_api.ts` defining the public API the packages expose
* applications and packages are assumed to have `*.html` and `*.css` files for components
* tests are in `*.spec.ts` files, written in jasmine, run with karma etc.

Underlying tools used include:
* karma + jasmine for testing
* esbuild for bundling

Additional conventions could be added such `*.e2e.ts` compiling as a separate suite of e2e tests, supporting `*.scss` etc.


## Development server

Run `bazel run //applications/demo:serve` for a dev server using bazel served at `http://localhost:8080/`.

Use `ibazel` (in place of `bazel` above) to automatically reload the browser when any changes to the application are compiled.

## Build

Run `bazel build //...`  to build the project using bazel. The build artifacts will be stored in the `bazel-bin/` directory.

## Running unit tests

Run `bazel test //...` to execute the unit tests using bazel.

# NOTE

Executing tests with `bazel test //...` currently fails on MacOS due to sandboxing issues. To debug tests run `bazel run //path/to:test`.
