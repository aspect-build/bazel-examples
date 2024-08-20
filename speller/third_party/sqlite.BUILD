load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_test")

# A modification of a starting point from:
# https://github.com/google/asylo
# with added Windows support

licenses(["unencumbered"])  # Public Domain

SQLITE_COPTS = [
    # https://sqlite.org/howtocompile.html
    # https://sqlite.org/compile.html
    "-DSQLITE_BYTEORDER=0",  # Compile-time detection is broken on ppc64le.
    "-DHAVE_DECL_STRERROR_R=1",
    "-DHAVE_FDATASYNC=1",
    "-DHAVE_INTTYPES_H=1",
    "-DHAVE_MEMORY_H=1",
    "-DHAVE_POSIX_FALLOCATE=0",
    "-DHAVE_STDINT_H=1",
    "-DHAVE_STDLIB_H=1",
    "-DHAVE_STRERROR_R=1",
    "-DHAVE_STRINGS_H=1",
    "-DHAVE_STRING_H=1",
    "-DHAVE_SYS_STAT_H=1",
    "-DHAVE_SYS_TYPES_H=1",
    "-DHAVE_UNISTD_H=1",
    "-DHAVE_USLEEP=1",
    "-DHAVE_GMTIME_R=1",
    "-w",
    # "-DSQLITE_OMIT_AUTOINIT",  # we must sqlite3_initialize(), else segfault!
    "-DSQLITE_ENABLE_COLUMN_METADATA",
    "-DSQLITE_ENABLE_FTS3",
    "-DSQLITE_ENABLE_RTREE",
    "-DSQLITE_ENABLE_UNLOCK_NOTIFY",
    "-DSQLITE_OMIT_LOAD_EXTENSION",
    "-DSQLITE_THREADSAFE=1",
    "-DSQLITE_USE_URI=1",
] + select({
    "@bazel_tools//src/conditions:windows": [],
    "//conditions:default": [
        "-Wno-error",
        "-DHAVE_LOCALTIME_R=1",
    ],
})

cc_library(
    name = "org_sqlite",
    srcs = [
        "sqlite3.c",  # The amalgamation file recommended by SQLite
    ],
    hdrs = [
        "sqlite3.h",
        "sqlite3ext.h",
    ],
    copts = SQLITE_COPTS,
    defines = [
        # Here instead of copts because it's referenced in the
        # sqlite3.h file.
        "SQLITE_OMIT_DEPRECATED",
    ],
    # One way to handle platform differences.
    linkopts =
        select({
            "@bazel_tools//src/conditions:windows": [],
            "//conditions:default": ["-lpthread"],
        }),
    visibility = ["//visibility:public"],
)

# bazel run @sqlite//:shell

cc_binary(
    name = "shell",
    srcs = ["shell.c"],
    copts = SQLITE_COPTS,
    visibility = ["//visibility:public"],
    deps = [":org_sqlite"],
)
