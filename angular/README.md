# Angular

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 14.0.2.
Then we added Bazel configuration files, without breaking the ability for the `ng` tooling to work.
This shows how a project can be in a "hybrid mode" where some developers (and maybe the CI system) can use Bazel, but others can continue using their familiar tools.

The `lib-a` and `common` projects were then added to demonstrate multiple projects with dependencies.

Look at the early commit history to this folder to better understand which changes were made after the Angular CLI created the project:
<https://github.com/aspect-build/bazel-examples/commits/main/angular>

## Development server

Run `ng serve` for a dev server using the Angular CLI.
Run `bazel run //:serve` for a dev server using bazel.

Navigate to `http://localhost:4200/`. The application will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory.
Run `bazel build //...`  to build the project using bazel. The build artifacts will be stored in the `bazel-bin/` directory.

## Running unit tests

Run `ng test` to execute the unit tests.
Run `bazel test //...` to execute the unit tests using bazel.

# NOTE

Executing tests with `bazel test //...` currently fails on MacOS due to sandboxing issues. To debug tests run `bazel run //path/to:test`.
