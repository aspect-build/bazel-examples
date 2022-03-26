load("@aspect_rules_swc//swc:swc.bzl", swc = "swc_rule")


# In Bazel 5, we could use a lambda to build a higher-order function
# but for Bazel 4 and below, we need partials.
def swc(args = [], swcrc = None):
    return 