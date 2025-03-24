load("@pip_types//:types.bzl", "types")
load("@rules_mypy//mypy:mypy.bzl", "mypy")

# Construct an instance of an aspect by applying configuration options to it.
# rules_mypy doesn't provide a default instance which is a feature, since it
# forces us to explicitly construct an instance and allows us to bypass the
# defaults in the ruleset.
mypy_aspect = mypy(
    types = types,
    mypy_cli = "@@//tools/mypy:mypy",
    mypy_ini = "@@//tools/mypy:mypy.ini",
    suppression_tags = [
        "no-mypy",
        "no-checks",
    ],
)
