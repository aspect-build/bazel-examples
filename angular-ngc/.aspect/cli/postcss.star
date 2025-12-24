aspect.gazelle_rule_kind("sass_binary", {
    "From": "//tools:sass.bzl",
    "MergeableAttrs": ["srcs"],
    "ResolveAttrs": ["deps"],
})

def declare_postcss(ctx):
    if len(ctx.sources) == 0:
        ctx.targets.remove("css")
        return

    imports = []
    for file in ctx.sources:
        imports.extend([
            aspect.Import(
                id = i.captures["import"],
                provider = "js",
                src = file.path,
            )
            for i in file.query_results["imports"]
        ])

    ctx.targets.add(
        name = "css",
        kind = "sass_binary",
        attrs = {
            "srcs": [src.path for src in ctx.sources],
            "deps": imports,
        },
    )

aspect.orion_extension(
    id = "postcss",
    prepare = lambda _: aspect.PrepareResult(
        sources = [
            aspect.SourceExtensions(".scss"),
        ],
        queries = {
            "imports": aspect.RegexQuery(
                filter = "**/*.scss",
                expression = """@use\\s+['"](?P<import>[^'"]+)['"]""",
            ),
        },
    ),
    declare = declare_postcss,
)
