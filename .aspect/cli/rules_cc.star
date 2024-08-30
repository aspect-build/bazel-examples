"""This Starlark file sets up the aspect rules in this example
repository to automatically generate several types of rules for C code.
"""

aspect.register_rule_kind("cc_binary", {
    "From": "@rules_cc//cc:defs.bzl",
    "MergeableAttrs": ["srcs"],
    "ResolveAttrs": ["deps"],
})
aspect.register_rule_kind("cc_library", {
    "From": "@rules_cc//cc:defs.bzl",
    "MergeableAttrs": ["srcs"],
    "ResolveAttrs": ["deps"],
})
aspect.register_rule_kind("cc_test", {
    "From": "@rules_cc//cc:defs.bzl",
    "MergeableAttrs": ["srcs"],
    "ResolveAttrs": ["deps"],
})

def add_target(ctx, file, hdrs = []):
    basename = file.path.removesuffix(".cc")
    deps = []
    for imp in file.query_results["imports"]:
        id = imp.captures["import"]

        # foo.cc and foo.h are in the same library, no import needed
        if id == basename:
            continue
        if id == "gtest/gtest":
            deps.append("@googletest//:gtest_main")
        elif id == "sqlite3":
            deps.append("@sqlite3")
        else:
            deps.append(aspect.Import(
                id = id,
                provider = "cc",
                src = file.path,
            ))
    is_test = basename.endswith("-test") or basename.endswith(".test")
    is_main = len(file.query_results["has_main"]) > 0
    attrs = {
        "srcs": [file.path],
        "hdrs": [h.path for h in hdrs],
        "deps": deps,
    }
    if is_test:
        attrs["size"] = "small"
    elif not is_main:
        attrs["visibility"] = ["//:__subpackages__"]

    ctx.targets.add(
        name = file.path[:file.path.rindex(".")] + "_lib",
        kind = "cc_test" if is_test else "cc_binary" if is_main else "cc_library",
        attrs = attrs,
        symbols = [aspect.Symbol(
            id = "/".join([ctx.rel, basename]) if ctx.rel else basename,
            provider = "cc",
        )],
    )

def declare(ctx):
    # pairs of implementation/header
    cc_header_pairs = []

    # unpaired files
    cc_files = []
    h_files = []

    for file in ctx.sources:
        if not file.path.endswith(".cc"):
            continue
        maybe_header = file.path.replace(".cc", ".h")
        matching_h = [h for h in ctx.sources if h.path == maybe_header]

        if len(matching_h) > 0:
            cc_header_pairs.append((file, matching_h[0]))
        else:
            cc_files.append(file)

    # FIXME: do something with unmatched .h files

    for file in cc_files:
        add_target(ctx, file)
    for pair in cc_header_pairs:
        add_target(ctx, pair[0], [pair[1]])

aspect.register_configure_extension(
    id = "cpp",
    prepare = lambda _: aspect.PrepareResult(
        sources = [aspect.SourceExtensions(".cc", ".h")],
        queries = {
            # TODO: use treesitter C++ once it's built into Aspect CLI
            "imports": aspect.RegexQuery(
                filter = "*.cc",
                expression = """#include\\s+"(?P<import>[^.]+).h\"""",
            ),
            "has_main": aspect.RegexQuery(
                filter = "*.cc",
                expression = "int\\s+main\\(",
            ),
        },
    ),
    declare = declare,
)
