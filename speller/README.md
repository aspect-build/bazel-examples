# Bazel examples

We use these examples to teach Bazel, but you are welcome to study them
for your own purposes!

## C++ Bazel setup

From a Github comment:

"Bazel is a really hard sell compared to other build systems when it is
only usable in one IDE (CLion) and only on one operating system
(Linux)."

But things are not as tough as that commenter suggested - many orgs have
local tweaks to make the tools sufficient for lots of Real Work.

## IntelliJ (CLion) Bazel integration has trouble on Windows

https://github.com/bazelbuild/intellij/issues/113

## MacOS workaround for CLion

To work around the error "Warning:Unable to check compiler version ...",

https://github.com/bazelbuild/intellij/issues/1545

add this to your shell setup:

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

## MacOS C/C++ debugging trouble

As of early 2022, debugging is broken by default for C/C++ on MacOS.
This issues describes the problem and links to several others.

https://github.com/bazelbuild/bazel/issues/6327

The problem can be worked around by disabling the sandbox, i.e. use the
local strategy:

build --spawn_strategy=local

Bazel does not consider the strategy as part of its cache key, so you may
need to clean the cache or change the source file to see this take effect.
Debugging then works in CLion.

The root cause is probably that nearly all Google developers work on Linux.
