# ts_project transpiler

This example shows how to use the
[ts_project `transpiler` attribute](https://bazelbuild.github.io/rules_nodejs/TypeScript.html#ts_project-transpiler)
to select a different transpiler tool rather than `tsc`.

Read our blog post: <https://blog.aspect.dev/typescript-speedup>

The example is in the `BUILD` file, where we have three builds:

1. As a reference, we first use `ts_project` without the `transpiler` attribute, so `tsc` does both type-checking and transpilation to JS. 

```
% bazel build tsc
...
# INFO: Elapsed time: 6.798s, Critical Path: 5.24s
```

2. Run [SWC](https://swc.rs/) to transpile ts -> js and tsc to type-check.

```
% bazel build swc
...
# INFO: Elapsed time: 0.745s, Critical Path: 0.54s
```

Note, you can explicitly do the slow type-check, and your CI would do this as well by running all tests.

```
$ bazel build swc_typecheck
...
# INFO: Elapsed time: 3.330s, Critical Path: 3.19s
```

3. Runs babel to transpile ts -> js and tsc to type-check.
This is slower than SWC, but might be needed if you currently
rely on babel plugins that aren't available in SWC yet.

```
% bazel build babel
...
# INFO: Elapsed time: 3.928s, Critical Path: 3.73s
```

Again, you could manually type-check the code if you like.
