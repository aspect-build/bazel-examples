load("@pip_types//:types.bzl", "types")
load("@rules_mypy//mypy:mypy.bzl", "mypy")

# Construct an instance of an aspect by applying configuration options to it.
# rules_mypy doesn't provide a default instance which is a feature, since it
# forces us to explicitly construct an instance and allows us to bypass the
# defaults in the ruleset.
mypy_aspect = mypy(
    types = types,
    mypy_cli = ":mypy",
    mypy_ini = ":mypy.ini",
)
