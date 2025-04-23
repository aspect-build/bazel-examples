#!/bin/sh
# See https://blog.aspect.build/run-tools-installed-by-bazel
target="//tools:$(basename "$0")"

# NB: we don't use 'bazel run' because it may leave behind zombie processes under ibazel
# shellcheck disable=SC2046
bazel 2>/dev/null build --build_runfile_links "$target" && \
  BAZEL_BINDIR=. exec $(bazel 2>/dev/null info execution_root)/$(bazel 2>/dev/null cquery --output=files "$target") "$@"