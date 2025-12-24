"Define linter aspects"

load("@aspect_rules_lint//lint:buf.bzl", "lint_buf_aspect")
load("@aspect_rules_lint//lint:checkstyle.bzl", "lint_checkstyle_aspect")
load("@aspect_rules_lint//lint:clang_tidy.bzl", "lint_clang_tidy_aspect")
load("@aspect_rules_lint//lint:eslint.bzl", "lint_eslint_aspect")
load("@aspect_rules_lint//lint:pmd.bzl", "lint_pmd_aspect")
load("@aspect_rules_lint//lint:ruff.bzl", "lint_ruff_aspect")
load("@aspect_rules_lint//lint:shellcheck.bzl", "lint_shellcheck_aspect")
load("@aspect_rules_lint//lint:keep_sorted.bzl", "lint_keep_sorted_aspect")

keep_sorted = lint_keep_sorted_aspect(
    binary = Label("@com_github_google_keep_sorted//:keep-sorted"),
)
# Check proto_library sources, see https://buf.build/docs/lint/overview
buf = lint_buf_aspect(
    config = "@@//:buf.yaml",
)

# Check ts_project and js_library sources, see https://eslint.org/
eslint = lint_eslint_aspect(
    binary = "@@//tools/lint:eslint",
    # ESLint will resolve the configuration file by looking in the working directory first.
    # See https://eslint.org/docs/latest/use/configure/configuration-files#configuration-file-resolution
    # We must also include any other config files we expect eslint to be able to locate, e.g. tsconfigs
    configs = [
        "@@//:eslintrc",
        "@@//logger/frontend:tsconfig",
    ],
)

ruff = lint_ruff_aspect(
    binary = "@multitool//tools/ruff",
    configs = ["@@//:.ruff.toml"],
)

shellcheck = lint_shellcheck_aspect(
    binary = "@multitool//tools/shellcheck",
    config = "@@//:.shellcheckrc",
)

clang_tidy = lint_clang_tidy_aspect(
    binary = "@@//tools/lint:clang_tidy",
    configs = ["@@//:.clang-tidy"],
    lint_target_headers = True,
    angle_includes_are_system = False,
    verbose = False,
)

pmd = lint_pmd_aspect(
    binary = "@@//tools/lint:pmd",
    rulesets = ["@@//:pmd.xml"],
)

checkstyle = lint_checkstyle_aspect(
    binary = "@@//tools/lint:checkstyle",
    config = "@@//:checkstyle.xml",
)
