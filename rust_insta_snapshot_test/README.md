# insta snapshot tests

An example for working with [insta](https://crates.io/crates/insta) snapshot tests under Bazel.

The `rust_snapshot_test` macro creates a `rust_test` which is run as a build action to create snapshots in the output tree, along with a `diff_test` to check whether any snapshots need to be applied. The diff test outputs a commands to run to review or accept the snapshot changes.

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
bazel run //:test_review
```

Or, to accept all snapshot changes without reviewing them:

```bash
bazel run //:test_accept
```

## Limitations

* There isn't a way to remove unreferenced snapshots when reviewing, though this may be supported in the future (see https://github.com/mitsuhiko/insta/blob/3aa59d6f94d1b0c25d5953231019aa1eadbb4017/cargo-insta/src/cli.rs#L1079).
