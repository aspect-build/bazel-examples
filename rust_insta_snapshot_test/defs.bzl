"""Macro for running rust insta snapshot tests"""

load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("@bazel_lib//lib:run_binary.bzl", "run_binary")
load("@bazel_lib//lib:utils.bzl", "utils")
load("@rules_rust//rust:defs.bzl", "rust_test")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

def rust_snapshot_test(name, snapshots_dir, **kwargs):
    """Creates a rust_test and runs it as a build action to produce snapshots in the output tree. Also creates accompanying diff_test and executable rules to review insta snapshots and write them back to the source tree.

    Args:
        name: Name of the test rule. The update rule name becomes {name}_review_snapshots.
        snapshots_dir: Directory containing snapshot files.
        **kwargs: Additional args to pass to rust_test
    """

    snapshots = native.glob(["{}/**".format(snapshots_dir)], exclude_directories = 1, allow_empty = True)

    rust_test(
        name = name,
        data = kwargs.pop("data", []) + snapshots,
        env = kwargs.pop("env", {}) | {
            # Re-root what insta considers to be the workspace root to the runfiles
            # root where the test binary runs. Otherwise, insta gets confused and looks
            # for snapshots next to the test binary in the output tree.
            # https://insta.rs/docs/advanced/#workspace-root
            "INSTA_WORKSPACE_ROOT": native.package_name(),
            # Updating snapshots automatically requires escaping the sandbox.
            # This is not bazel idiomatic, so simply fail the test and report the
            # diffs. Leave actually updating snapshots to the "update" executable rule
            # below.
            "INSTA_OUTPUT": "diff",
            "INSTA_UPDATE": "no",
        },
        testonly = False,
        # Don't run the rust_test on test //... like a normal test.
        # We only use it as input to a run_binary to produce snapshots.
        tags = kwargs.get("tags", []) + ["manual"],
        **kwargs
    )

    # Run the test binary to produce snapshots as build artifacts
    run_binary(
        name = "{}_snapshots".format(name),
        tool = ":{}".format(name),
        srcs = snapshots,
        env = {
            # We want to produce all snapshot outputs so never fail a test on a mismatched snaptho.
            "INSTA_FORCE_PASS": "1",
            "INSTA_OUTPUT": "diff",
            # Always write the full canonical snapshots to the output tree so they can be compared to
            # the copy in the source tree.
            "INSTA_UPDATE": "always",
            # Re-root under a __{name}_snapshots folder in the bin directory. The snapshots folder created by insta
            # is always named "snapshots", and we want to avoid clobbering the source snapshots folder as
            # an input to the diff_test rule below.
            # # https://insta.rs/docs/advanced/#workspace-root
            "INSTA_WORKSPACE_ROOT": "/".join(["$(BINDIR)", native.package_name(), "__{}_snapshots".format(name)]),
        },
        out_dirs = ["__{}_snapshots/{}".format(name, snapshots_dir)],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

    sh_binary(
        name = "{}_rewrite_paths_bin".format(name),
        srcs = ["rewrite_snapshot_paths.sh"],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

    # Rewrite the "source" entry in the snapshot header which was written as a relative
    # path in the output tree back to its source tree equivalent so that the diff test
    # will succeed.
    # E.g., source: "../../../../src/test.rs" -> "src/test.rs"
    run_binary(
        name = "{}_rewrite_paths".format(name),
        srcs = [":{}_snapshots".format(name), "@sed//:sed"],
        tool = ":{}_rewrite_paths_bin".format(name),
        args = ["$(execpath @sed//:sed)", "$(execpath :{}_snapshots)".format(name), "$(@D)", ("/".join(["$(BINDIR)", native.package_name(), "__{}_snapshots".format(name)]) + "/").replace("//", "/")],
        out_dirs = ["__{}_snapshots_fixed_paths".format(name)],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

    # If the snapshots directory doesn't exist, fail with a message indicating how to create it
    if _is_file_missing(utils.to_label(snapshots_dir)):
        fail_with_message_test(
            name = "{}_missing_test".format(name),
            message = """
            {snapshots_dir} does not exist. To review and create snapshots, run:

                bazel run //{pkg}:{name}_review_snapshots

            To create all snapshots, run:

                bazel run //{pkg}:{name}_accept_snapshots

""".format(snapshots_dir = snapshots_dir, pkg = native.package_name(), name = name),
            size = "small",
            tags = kwargs.get("tags"),
            visibility = kwargs.get("visibility"),
        )
    else:
        # Test that snapshots in the source tree match the ones in the output tree
        diff_test(
            name = "{}_diff_test".format(name),
            file1 = snapshots_dir,
            file2 = ":{}_rewrite_paths".format(name),
            failure_message = """
To review snapshots, run:

    bazel run //{pkg}:{name}_review_snapshots

To accept all snapshots, run:

    bazel run //{pkg}:{name}_accept_snapshots

""".format(pkg = native.package_name(), name = name),
            tags = kwargs.get("tags"),
            visibility = kwargs.get("visibility"),
        )

    # Run `cargo insta review` on snapshots in the source tree
    sh_binary(
        name = "{}_review_snapshots".format(name),
        srcs = ["insta_review.sh"],
        args = [
            "$(rootpath @bindeps//:cargo-insta__cargo-insta)",
            "$(rootpath :{}_rewrite_paths)".format(name),
            snapshots_dir,
            "review",
        ],
        data = snapshots + [
            ":{}_rewrite_paths".format(name),
            "@bindeps//:cargo-insta__cargo-insta",
        ],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

    # Run `cargo insta accept` on snapshots in the source tree
    sh_binary(
        name = "{}_accept_snapshots".format(name),
        srcs = ["insta_review.sh"],
        args = [
            "$(rootpath @bindeps//:cargo-insta__cargo-insta)",
            "$(rootpath :{}_rewrite_paths)".format(name),
            snapshots_dir,
            "accept",
        ],
        data = snapshots + [
            ":{}_rewrite_paths".format(name),
            "@bindeps//:cargo-insta__cargo-insta",
        ],
        tags = kwargs.get("tags"),
        visibility = kwargs.get("visibility"),
    )

# Copied from https://github.com/bazel-contrib/bazel-lib/blob/3da75683f3ed4ba81b4f83e3306bb41bce20da28/lib/private/write_source_file.bzl#L464
def _is_file_missing(label):
    """Check if a file is missing by passing its relative path through a glob()

    Args
        label: the file's label
    """
    file_abs = "%s/%s" % (label.package, label.name)
    file_rel = file_abs[len(native.package_name()) + 1:]
    file_glob = native.glob([file_rel], exclude_directories = 0, allow_empty = True)

    # Check for subpackages in case the expected output contains BUILD files,
    # the above files glob will return empty.
    subpackage_glob = []
    if hasattr(native, "subpackages"):
        subpackage_glob = native.subpackages(include = [file_rel], allow_empty = True)

    return len(file_glob) == 0 and len(subpackage_glob) == 0

# Copied from https://github.com/bazel-contrib/bazel-lib/blob/3da75683f3ed4ba81b4f83e3306bb41bce20da28/lib/private/fail_with_message_test.bzl
def _fail_with_message_test_impl(ctx):
    fail(ctx.attr.message)

fail_with_message_test = rule(
    attrs = {
        "message": attr.string(mandatory = True),
    },
    implementation = _fail_with_message_test_impl,
    test = True,
)
