load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "aspect_rules_js",
    sha256 = "dda5fee3926e62c483660b35b25d1577d23f88f11a2775e3555b57289f4edb12",
    strip_prefix = "rules_js-1.6.9",
    url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.6.9.tar.gz",
)

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    pnpm_lock = "//:pnpm-lock.yaml",
    verify_node_modules_ignored = "//:.bazelignore",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

http_archive(
    name = "aspect_rules_rollup",
    sha256 = "bca82203e3bbcf1202011b25fc8e369fc2ed641a60e293500d64884a18a77b6f",
    strip_prefix = "rules_rollup-0.12.1",
    url = "https://github.com/aspect-build/rules_rollup/archive/refs/tags/v0.12.1.tar.gz",
)

load("@aspect_rules_rollup//rollup:repositories.bzl", "rollup_repositories")

# TODO(alexeagle): use the same rollup version from package.json
rollup_repositories(name = "rollup")

load("@rollup//:npm_repositories.bzl", rollup_npm_repositories = "npm_repositories")

rollup_npm_repositories()
