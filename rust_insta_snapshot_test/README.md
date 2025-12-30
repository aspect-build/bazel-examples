# insta snapshot tests

An example for working with [insta](https://crates.io/crates/insta) snapshot tests under Bazel.

The `rust_snapshot_test` macro creates runs a `rust_test` which is uses as a build action to create snapshots in the output tree, along with a `diff_test` to compare the output to the source tree snapshots.
When the snapshots have changes, the test will fail and will output a command to review and update the snapshots, similar to a [write_source_files](https://registry.bazel.build/docs/bazel_lib/3.0.0#lib-write_source_files-bzl) flow.

```starlark
rust_snapshot_test(
    name = "test",
    snapshots_dir = "src/snapshots",
    srcs = ["src/test.rs"],
    crate_root = "src/test.rs",
    deps = [
        "@crate_index//:insta",
    ],
)
```

Snapshots can be interactively reviewed using insta and written back to the source tree. For example, the following command runs `cargo insta review`.

```bash
bazel run //:test_review_snapshots
```

Or, to accept all snapshot changes without reviewing them:

```bash
bazel run //:test_accept_snapshots
```

## Limitations

* This is intended as a toy example; there are probably edge cases not covered.
