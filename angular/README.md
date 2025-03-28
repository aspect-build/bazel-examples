# Angular

This project was generated using [Angular CLI](https://github.com/angular/angular-cli) version 20.0.0-next.3.

We ran `ng generate application my-app` and `ng generate application my-lib`.

Bazel BUILD files were then added to the my-app and my-lib folders.

## Development server

To start a local development server using "native" tooling, run:

```bash
../tools/ng serve
```

To start it with Bazel, run:

```bash
npm start
```

Once the server is running, open your browser and navigate to `http://localhost:4200/`. The application will automatically reload whenever you modify any of the source files.

## Code scaffolding

Angular CLI includes powerful code scaffolding tools. To generate a new component, run:

```bash
../tools/ng generate component component-name
```

For a complete list of available schematics (such as `components`, `directives`, or `pipes`), run:

```bash
../tools/ng generate --help
```

## Building

To build the project using "native" tooling, run:

```bash
../tools/ng build
```

To build with Bazel, run:

```bash
npm run build
```

This will compile your project and store the build artifacts in the `dist/` directory. By default, the production build optimizes your application for performance and speed.

## Running unit tests

To execute unit tests with the [Karma](https://karma-runner.github.io) test runner and "native" tools, use the following command:

```bash
ng test
```

To run them with Bazel, run:

```bash
npm test
```

## Running end-to-end tests

For end-to-end (e2e) testing, run:

```bash
ng e2e
```

Angular CLI does not come with an end-to-end testing framework by default. You can choose one that suits your needs.

## Additional Resources

For more information on using the Angular CLI, including detailed command references, visit the [Angular CLI Overview and Command Reference](https://angular.dev/tools/cli) page.
