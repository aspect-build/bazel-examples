# TODO: delete when all rules_js rules added to aspect-cli
aspect.register_rule_kind("js_binary", {
    "From": "@aspect_rules_js//js:defs.bzl",
    "MergeableAttrs": ["data"],
    "ResolveAttrs": ["entry_point", "data"],
})

def declare_main_js(ctx):
    if len(ctx.sources) == 0:
        ctx.targets.remove("main")
        return

    entry_point = ctx.sources[0].path.replace(".ts", ".js")

    ctx.targets.add(
        name = "main",
        kind = "js_binary",
        attrs = {
            # The entry point file
            "entry_point": entry_point,
            "data": [
                aspect.Label(
                    pkg = ctx.rel,
                    name = "tsc",
                ),
            ],
        },
    )

aspect.register_configure_extension(
    id = "main_js",
    prepare = lambda _: aspect.PrepareResult(
        sources = [aspect.SourceFiles("src/main.js", "src/main.ts")],
    ),
    declare = declare_main_js,
)
