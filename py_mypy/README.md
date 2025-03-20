# Using MyPy with rules_python

This is a walkthrough of using [rules_mypy](https://github.com/theoremlp/rules_mypy) together with `rules_python` to apply typechecks as part of "building" a Python application.

## How MyPy will work

Bazel's [aspects](https://bazel.build/extending/aspects) allow extensions to traverse the build graph and apply rewrites to it between the analysis pass and before `build` happens.
A common application of aspects is to "bolt on" behavior to existing rules without having to modify them.
Which is exactly what we're going to do here.

One way that an aspect can extend an existing rule is by adding an [`OutputGroupInfo`](https://bazel.build/versions/7.4.0/rules/lib/providers/OutputGroupInfo) provider to the rule.
Output groups are a slightly unusual feature which allows for rule names to be overloaded, and for a rule to provide multiple kinds of outputs.
To take a slightly familiar example, the `py_binary` rule normally outputs a launcher script and a `.runfiles` tree, but it also provides a zipapp output which can be selectively enabled.
Outputs may be selected during a build using the [`--output_groups`](https://bazel.build/reference/command-line-reference#flag--output_groups) flag.

Notionally how this will all work is that:

- We need to create an aspect configured to use whatever `mypy` tool we may want
- That aspect will extend the `py_*` rules in the build graph to add an output group capturing the MyPy typecheck cache.
  These typecheck cache outputs will depend on the typecheck cache outputs of all dependencies.
- We will configure our `.bazelrc` to apply the aspect so that users don't have to think about it.
- We will configure our `.bazelrc` to select the typecheck output group in addition to the default outputs of rules.

This all has the effect of creating a build sub-graph parallel to our normal build graph which instead of producing and consuming Python files as dependencies produces and consumes the MyPy analysis caches.

To take a simple example, let's say that we have a small build graph

```mermaid
graph TD
    A[data_models] --> B[data_persistence];
    A --> C[inventory_management];
    A --> D[order_processing];
    B --> C;
    B --> D;
    C --> E[cli];
    D --> E;
    F["click (3rdparty)"] --> E;
    G["pydantic (3rdparty)"] --> A;
```

Ordinarily the dependencies between these rules take the form of the Python source files underlying the rules.
But when we activate our `mypy` aspect and select the `mypy` output group, the cache files from typechecking each* of these targets also become part of that dependency chain.
This allows Bazel to drive typechecking these libraries in depgraph order while caching intermediate results.

We can demonstrate this by looking at the results of `bazel aquery`, which will show MyPy invocations and that the resulting cache trees are dependencies between each of the invocations.
But more on that in a minute.

## Setup

In this example we've set up `rules_python` in combination with `rules_uv`, which provides lockfile compilation.
These two give us a Python dependency solution (including the MyPy we want to use), which we'll feed into `rules_mypy`.

The main trick is in `//tools/mypy:BUILD.bazel`, where we provide a definition of the MyPy CLI binary which we can feed into the checking aspect.
This is important because it allows us to use our locked requirement for MyPy, and to provide MyPy plugins.
If we didn't do this, `rules_mypy` would "helpfully" provide an embedded default version and configuration of MyPy which may or may not be what we want.

We also need the `.bazelrc` as previously discussed to enable both the aspect and the typecheck output group.

## Demo

If we use `bazel aquery //projects/cli`, we will see among much other output

```
action 'mypy //projects/cli:cli'
  Mnemonic: mypy
  Target: //projects/cli:cli
  Configuration: darwin_arm64-fastbuild
  Execution platform: @@platforms//host:host
  AspectDescriptors: [
    //tools/mypy:defs.bzl%mypy_aspect(cache='true', color='true')
]
  ActionKey: ...
  Inputs: [
    bazel-out/.../bin/projects/inventory_management/inventory_management.mypy_cache,
    bazel-out/.../bin/projects/order_processing/order_processing.mypy_cache,
    bazel-out/.../bin/tools/mypy/mypy,
    ...
  ]
```

This is the actual typecheck action of the `//projects/cli:cli` target, showing that as inputs it takes (among many other things) the `.mypy_cache` tree results from typechecking the two sub-libraries `inventory_management` and `order_processing`.

If we dig around in the action plan a bit more, we'll also find the typecheck definitions for those products.
For instance if we inspect the `inventory_management` build, we'll find the production action for those cache files.

```
action 'mypy //projects/inventory_management:inventory_management'
  Mnemonic: mypy
  Target: //projects/inventory_management:inventory_management
  Configuration: darwin_arm64-fastbuild
  Execution platform: @@platforms//host:host
  AspectDescriptors: [
    //tools/mypy:defs.bzl%mypy_aspect(cache='true', color='true')
  ]
  ActionKey: ...
  Inputs: [
    bazel-out/.../bin/projects/data_models/data_models.mypy_cache,
    bazel-out/.../bin/tools/mypy/mypy,
    ...
  ]
```

This demonstrates that the `rules_mypy` configuration will perform incremental typechecking (only targets which changed will be re-checked except in the case of a cascading failure), to the limit of 1stparty code.

Per [rules_mypy#23](https://github.com/theoremlp/rules_mypy/issues/23), the aspect which creates typecheck rules short-circuits and stops to create annotations when it encounters 3rdparty code.
This bypasses the problem of attempting to apply 1stparty typecheck rules to code which may not conform to them, but creates the problem that because there is no shared `pyspark.mypy_cache` output, 3rdparty libraries may be typechecked (or at least analyzed as part of typechecking) more than once.
