load("@npm//:sass/package_json.bzl", sass_bin = "bin")

# Convert sass input to output filename
def _sass_out(n):
    return n.replace(".scss", ".css")

def sass(name, srcs, deps = [], **kwargs):
    """Runs SASS on the source files and output the resulting .css

    Args:
        name: A unique name for the terminal target
        srcs: A list of .scss sources
        deps: A list of sass dependencies
        **kwargs: Additional arguments
    """
    sass_bin.sass(
        name = name,
        srcs = srcs + deps,
        outs = [_sass_out(src) for src in srcs] + ["%s.map" % _sass_out(src) for src in srcs],
        args = [
            "--load-path=node_modules",
        ] + [
            "$(execpath {}):{}/{}".format(src, native.package_name(), _sass_out(src))
            for src in srcs
        ],
        **kwargs
    )
