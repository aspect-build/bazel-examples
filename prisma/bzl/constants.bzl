"""Constants relating to prisma engines / platforms."""

# https://github.com/prisma/prisma/blob/e0273500754e27f2b37ad709dde7dd73db40bd2a/packages/get-platform/src/platforms.ts#L30-L57
#
# Platforms that are commented out are currently not supported.
#
# The config settings here mirror the logic in
# https://github.com/prisma/prisma/blob/a84b1f00954311fcd27ece43370f928e20a564d2/packages/get-platform/src/getPlatform.ts#L465-L583
PLATFORMS = {
    "darwin": struct(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:macos",
        ],
    ),
    "darwin-arm64": struct(
        constraint_values = [
            "@platforms//cpu:arm64",
            "@platforms//os:macos",
        ],
    ),
    "debian-openssl-1.0.x": struct(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
            "//constraints:linux_debian",
            "//constraints:openssl_1.0",
        ],
    ),
    "debian-openssl-1.1.x": struct(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
            "//constraints:linux_debian",
            "//constraints:openssl_1.1",
        ],
    ),
    "debian-openssl-3.0.x": struct(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
            "//constraints:linux_debian",
            "//constraints:openssl_3",
        ],
    ),
    "linux-arm64-openssl-1.0.x": struct(
        constraint_values = [
            "@platforms//cpu:arm64",
            "@platforms//os:linux",
            "//constraints:openssl_1.0",
        ],
    ),
    # Distro detection doesn't support RHEL.
    #"rhel-openssl-1.0.x",
    #"rhel-openssl-1.1.x",
    #"rhel-openssl-3.0.x",
    "linux-arm64-openssl-1.1.x": struct(
        constraint_values = [
            "@platforms//cpu:arm64",
            "@platforms//os:linux",
            "//constraints:openssl_1.1",
        ],
    ),
    "linux-arm64-openssl-3.0.x": struct(
        constraint_values = [
            "@platforms//cpu:arm64",
            "@platforms//os:linux",
            "//constraints:openssl_3",
        ],
    ),
    # linux-arm-openssl-* fail to downloads (see #179)
    #"linux-arm-openssl-1.1.x",
    #"linux-arm-openssl-1.0.x",
    #"linux-arm-openssl-3.0.x",
    "linux-musl": struct(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
            "//constraints:linux_musl",
        ],
    ),
    "linux-musl-arm64-openssl-1.1.x": struct(
        constraint_values = [
            "@platforms//cpu:arm64",
            "@platforms//os:linux",
            "//constraints:linux_musl",
            "//constraints:openssl_1.1",
        ],
    ),
    "linux-musl-arm64-openssl-3.0.x": struct(
        constraint_values = [
            "@platforms//cpu:arm64",
            "@platforms//os:linux",
            "//constraints:linux_musl",
            "//constraints:openssl_3",
        ],
    ),
    "linux-musl-openssl-3.0.x": struct(
        constraint_values = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
            "//constraints:linux_musl",
            "//constraints:openssl_3",
        ],
    ),
    #"linux-nixos", // nixios not in platforms/os
    "windows": struct(
        constraint_values = [
            "@platforms//os:windows",
        ],
    ),
    # FreeBSD version detection not built.
    #"freebsd11",
    #"freebsd12",
    #"freebsd13",
    #"openbsd", // fails to download, see #179
    #"netbsd", // netbsd not in platforms/os (yet)
    #"arm", // unclear when arm would ever be selected.
}

# https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/fetch-engine/src/BinaryType.ts
QUERY_ENGINE_BINARY = "query-engine"
QUERY_ENGINE_LIBRARY = "libquery-engine"
SCHEMA_ENGINE_BINARY = "schema-engine"

BINARY_TYPES = [QUERY_ENGINE_BINARY, QUERY_ENGINE_LIBRARY, SCHEMA_ENGINE_BINARY]
