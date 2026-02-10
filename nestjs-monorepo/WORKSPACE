workspace(
    name = "nestjs-bazel-monorepo-example",
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "aspect_rules_js",
    sha256 = "630a71aba66c4023a5b16ab3efafaeed8b1a2865ccd168a34611eb73876b3fc4",
    strip_prefix = "rules_js-1.37.1",
    url = "https://github.com/aspect-build/rules_js/releases/download/v1.37.1/rules_js-v1.37.1.tar.gz",
)

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = "18.17.0",
)

http_archive(
    name = "aspect_bazel_lib",
    sha256 = "979667bb7276ee8fcf2c114c9be9932b9a3052a64a647e0dcaacfb9c0016f0a3",
    strip_prefix = "bazel-lib-2.4.1",
    url = "https://github.com/aspect-build/bazel-lib/releases/download/v2.4.1/bazel-lib-v2.4.1.tar.gz",
)

# For convenience, npm_translate_lock does this call automatically.
# Uncomment if you don't call npm_translate_lock at all.
#load("@bazel_features//:deps.bzl", "bazel_features_deps")
#bazel_features_deps()


# load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

# yarn_install(
#     name = "yarni",
#     package_json = "//:package.json",
#     symlink_node_modules = True,
#     yarn_lock = "//:yarn.lock",
# )

load("@aspect_rules_js//npm:repositories.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    yarn_lock = "//:yarn.lock",
    verify_node_modules_ignored = "//:.bazelignore",
    pnpm_lock = "//:pnpm-lock.yaml",
    data = ["//:package.json"],
    update_pnpm_lock = True,
    npmrc = "//:.npmrc",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

http_archive(
    name = "aspect_rules_swc",
    sha256 = "8eb9e42ed166f20cacedfdb22d8d5b31156352eac190fc3347db55603745a2d8",
    strip_prefix = "rules_swc-1.1.0",
    url = "https://github.com/aspect-build/rules_swc/releases/download/v1.1.0/rules_swc-v1.1.0.tar.gz",
)

load("@aspect_rules_swc//swc:dependencies.bzl", "rules_swc_dependencies")

rules_swc_dependencies()

load("@aspect_rules_swc//swc:repositories.bzl", "LATEST_SWC_VERSION", "swc_register_toolchains")

swc_register_toolchains(
    name = "swc",
    swc_version = LATEST_SWC_VERSION,
)

http_archive(
    name = "aspect_rules_ts",
    sha256 = "6ad28b5bac2bb5a74e737925fbc3f62ce1edabe5a48d61a9980c491ef4cedfb7",
    strip_prefix = "rules_ts-2.1.1",
    url = "https://github.com/aspect-build/rules_ts/releases/download/v2.1.1/rules_ts-v2.1.1.tar.gz",
)

##################
# rules_ts setup #
##################
# Fetches the rules_ts dependencies.
# If you want to have a different version of some dependency,
# you should fetch it *before* calling this.
# Alternatively, you can skip calling this function, so long as you've
# already fetched all the dependencies.
load("@aspect_rules_ts//ts:repositories.bzl", "rules_ts_dependencies")

rules_ts_dependencies(
    # This keeps the TypeScript version in-sync with the editor, which is typically best.
    ts_version_from = "//:package.json",
    # Alternatively, you could pick a specific version, or use
    # load("@aspect_rules_ts//ts:repositories.bzl", "LATEST_TYPESCRIPT_VERSION")
    # ts_version = "5.1.3"
)

# jest for test nestjs
http_archive(
    name = "aspect_rules_jest",
    sha256 = "49c688e3838c855a9acf3b77bc25cfb18bdd70b03ff0810fbfd6353dd6055feb",
    strip_prefix = "rules_jest-0.20.0",
    url = "https://github.com/aspect-build/rules_jest/releases/download/v0.20.0/rules_jest-v0.20.0.tar.gz",
)


load("@aspect_rules_jest//jest:dependencies.bzl", "rules_jest_dependencies")

rules_jest_dependencies()

