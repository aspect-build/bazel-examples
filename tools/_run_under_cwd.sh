#!/bin/sh
# See https://blog.aspect.build/run-tools-installed-by-bazel
case "$(basename "$0")" in
  go)
    # https://github.com/bazelbuild/rules_go/blob/master/docs/go/core/bzlmod.md#using-a-go-sdk
    target="@rules_go//go"
    ;;
  pnpm)
    # https://github.com/aspect-build/rules_js/blob/main/docs/faq.md#can-i-use-bazel-managed-pnpm
    target="@pnpm"
    ;;
  *)
    target="@multitool//tools/$(basename "$0")"
    ;;
esac
# NB: we don't use 'bazel run' because it may leave behind zombie processes under ibazel
bazel 2>/dev/null build "$target" && BAZEL_BINDIR=. exec $(bazel info execution_root)/$(bazel 2>/dev/null cquery --output=files "$target") "$@"
