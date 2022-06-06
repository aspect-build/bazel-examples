# vue-project

Created by running `npm init vue@latest` following https://vuejs.org/guide/quick-start.html#local

Then adding Bazel configuration files.

Note: this project simply wraps the Vite build system with Bazel.
This doesn't provide any incrementality benefits of Bazel, because it just runs a single action
when any file changes, which calls through to Vite.

To be more Bazel-idiomatic, the Vite composition of tools like `esbuild` and 
plugins like `@vitejs/plugin-vue` should be decomposed into an analogous Bazel pipeline.
