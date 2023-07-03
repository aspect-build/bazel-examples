"""Repository rules for https://github.com/vercel/pkg-fetch

This is a transitive dependency of vercel/pkg which we explicitly fetch with Bazel downloader
so that it doesn't fetch lazily when the action runs.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

# The version can be found in the /pnpm-lock.yaml file:
#  /pkg/5.8.1:
#   ...
#  pkg-fetch: 3.4.2
PKG_FETCH_VERSION = "3.4"

# Node versions mirrored into the pkg-fetch releases:
# https://github.com/vercel/pkg-fetch/releases/tag/v3.4
# TODO(#2631): should match our node_version in WORKSPACE nodejs_register_toolchains
PKG_FETCH_NODE_VERSION = "16.16.0"
PKG_FETCH_VENDORED_NODE = {
    "c38f270d190fd1f5d8e74800b62408d06f4492720fec1fd46414a7f504114847": "alpine-arm64",
    "2c4caf90c620f4839277edf8dfb4fd1d259294a2bfbed2b90bb6063a6e0c9d23": "alpine-x64",
    "e3913ecef725f83ccbd2181d7d33043f8b3e72466d09897c338ee328cffc3bfe": "linux-arm64",
    "f1a561aadf78e438e73b043a3c5d7b9fe075d7abcaaec6f29d9e2a0ba00d3a69": "linux-x64",
    "aac0039a2b380057085a4b927637c6e5550eabfd55d1ca2f98e022abccfd7390": "linuxstatic-arm64",
    "cbe14ff111fd3d1ecb82cf6aaec5a53588537008fdcfab4bc2c880d651f5580a": "linuxstatic-armv7",
    "8a888553a4855f3b01ea91a398eb3112b0d5f58f5f0112e9fecf6621615201ce": "linuxstatic-x64",
    "d9140eebaa88620b9692d6e11cc2d92b2b56f791a6bbeddd771f5e07d042e1bc": "macos-arm64",
    "321fcef798383c6e19d7ae242bc73dd1f1c7471499b00ee6b105c764645d9263": "macos-x64",
    "e078fd200f6f0cd2e84ba668711a5cc9c7f0d20d36fae1bfe4bc361f40f5923f": "win-arm64",
    "b6c5f9a5bce3b451b6d59153eae6db1a87016edc3775ef9eae39f86485735672": "win-x64",
}

def pkg_fetch_deps(_):
    for (sha256, platform) in PKG_FETCH_VENDORED_NODE.items():
        http_file(
            name = "pkg_fetch_node_{}".format(platform.replace("-", "_")),
            # Match the path of what the `pkg` program would do dynamically.
            downloaded_file_path = "v{}/fetched-v{}-{}".format(
                PKG_FETCH_VERSION,
                PKG_FETCH_NODE_VERSION,
                platform,
            ),
            sha256 = sha256,
            urls = ["https://github.com/vercel/pkg-fetch/releases/download/v{}/node-v{}-{}".format(
                PKG_FETCH_VERSION,
                PKG_FETCH_NODE_VERSION,
                platform,
            )],
        )

pkg_fetch = module_extension(
    implementation = pkg_fetch_deps,
)
