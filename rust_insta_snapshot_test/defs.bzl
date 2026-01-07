"""Macro for running rust insta snapshot tests"""

load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@bazel_lib//lib:run_binary.bzl", "run_binary")
load("@rules_rust//rust:defs.bzl", "rust_test")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

def rust_snapshot_test(name, snapshots_dir, **kwargs):
    """Create a rust_test and run it as a build action to produce snapshots in the output tree. Also creates a diff_test to check for snapshots that need reviewing, and executable rules to review the snapshots and write them back to the source tree.

    Args:
        name: Name of the test rule
        snapshots_dir: Directory containing snapshot files
        **kwargs: Additional args to pass to rust_test
    """

    snapshots = native.glob(["{}/**".format(snapshots_dir)], exclude_directories = 1, allow_empty = True)

    # This test is tagged as "manual" because it is not meant to be run as a test target.
    # Instead, it's run as a build action below with run_binary to produce snapshots as
    # built artifacts.
    rust_test(
        name = name,
        data = kwargs.pop("data", []) + snapshots,
        # Set some env vars that will allow the tests to correct run if the target is ever
        # tested manually. The env vars needed for the run-as-build-action case are different below.
        env = kwargs.pop("env", {}) | {
            # Re-root what insta considers to be the workspace root to the runfiles
            # root where the test binary runs. Otherwise, insta gets confused and looks
            # for snapshots next to the test binary in the output tree.
            # https://insta.rs/docs/advanced/#workspace-root
            "INSTA_WORKSPACE_ROOT": native.package_name(),
            # Updating snapshots automatically requires escaping the sandbox.
            # This is not bazel idiomatic, so simply fail the test and report the
            # diffs. Leave actually updating snapshots to the executable targets below.
            "INSTA_OUTPUT": "diff",
            "INSTA_UPDATE": "no",
        },
        testonly = False,
        tags = kwargs.get("tags", []) + ["manual"],
        **kwargs
    )

    # Run the test binary to produce snapshots as build artifacts
    run_binary(
        name = "{}_snapshots".format(name),
        tool = ":{}".format(name),
        srcs = snapshots + ["Cargo.toml"] + native.glob(["src/**/*.rs"]),
        env = {
            # We want to produce all snapshot outputs so never fail a test on a mismatched snapshot
            "INSTA_FORCE_PASS": "1",
            "INSTA_OUTPUT": "diff",
            # Write snapshot differentials as build artifacts
            "INSTA_UPDATE": "new",
            "INSTA_WORKSPACE_ROOT": native.package_name(),
            # Output snapshots in the output tree rather than next to the source files
            "INSTA_PENDING_DIR": "/".join(["$(RULEDIR)", "{}_snapshots".format(name)]),
        },
        out_dirs = ["{}_snapshots".format(name)],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

    copy_to_directory(
        name = "{}_empty_dir".format(name),
    )

    # Compare the snapshot outputs to an empty directory. If it passes, then there
    # are no snapshot changes to apply.
    diff_test(
        name = "{}_diff_test".format(name),
        file1 = ":{}_empty_dir".format(name),
        file2 = ":{}_snapshots".format(name),
        failure_message = """
There are unreviewed changes to snapshots.

To review snapshots, run:

    bazel run //{pkg}:{name}_review

To accept all changes, run:

    bazel run //{pkg}:{name}_accept

""".format(pkg = native.package_name(), name = name),
        # Use no-sandbox because sandboxing under bazel won't include symlinks
        # to empty directories in the output tree in the runfiles tree
        tags = kwargs.get("tags", []) + ["no-sandbox"],
        visibility = kwargs.get("visibility"),
    )

    # Run `cargo insta review` on snapshots in the source tree
    sh_binary(
        name = "{}_review".format(name),
        srcs = ["insta.sh"],
        args = [
            "$(rootpath @bindeps//:cargo-insta__cargo-insta)",
            "$(rootpath :{}_snapshots)".format(name),
            snapshots_dir,
            "review",
        ],
        data = snapshots + [
            ":{}_snapshots".format(name),
            "@bindeps//:cargo-insta__cargo-insta",
        ],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

    # Run `cargo insta accept` on snapshots in the source tree
    sh_binary(
        name = "{}_accept".format(name),
        srcs = ["insta.sh"],
        args = [
            "$(rootpath @bindeps//:cargo-insta__cargo-insta)",
            "$(rootpath :{}_snapshots)".format(name),
            snapshots_dir,
            "accept",
        ],
        data = snapshots + [
            ":{}_snapshots".format(name),
            "@bindeps//:cargo-insta__cargo-insta",
        ],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )
