"Macro definitions to make shorter BUILD files for calling Angular CLI via the architect subsystem"

load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_to_bin")
load("@aspect_bazel_lib//lib:jq.bzl", "jq")
load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@npm//angular19:@angular-devkit/architect-cli/package_json.bzl", architect_cli = "bin")

# JQ expressions to update Angular project output paths from dist/* to projects/*/dist
JQ_DIST_REPLACE_TSCONFIG = """
    .compilerOptions.paths |= map_values(
      map(
        gsub("^dist/(?<p>.+)$"; "projects/"+.p+"/dist")
      )
    )
"""
JQ_DIST_REPLACE_NG_PACKAGE = """.dest = "dist" """

def node_modules(pkgs):
    return ["//angular19:node_modules/" + s for s in pkgs]

COMMON_CONFIG = "//angular19:ng-config"

LIBRARY_DEPS = node_modules([
    "@angular/common",
    "@angular/core",
    "@angular/router",
    "rxjs",
    "tslib",
])

# Common dependencies of Angular CLI libraries
LIBRARY_CONFIG = [
    ":tsconfig.lib.json",
    ":tsconfig.lib.prod.json",
    ":package.json",
]

APPLICATION_CONFIG = [
    ":tsconfig.app.json",
]

APPLICATION_DEPS = node_modules([
    "@angular/common",
    "@angular/core",
    "@angular/router",
    "@angular/platform-browser",
    "@angular/platform-browser-dynamic",
    "rxjs",
    "tslib",
    "zone.js",
])

TEST_DEPS = node_modules([
    "@angular/core",
    "@angular/compiler",
    "@angular/platform-browser",
    "@angular/platform-browser-dynamic",
    "@types/jasmine",
    "jasmine-core",
    "karma-chrome-launcher",
    "karma-coverage",
    "karma-jasmine",
    "karma-jasmine-html-reporter",
    "tslib",
    "zone.js",
])

TEST_CONFIG = [
    ":tsconfig.spec.json",
]

TOOLS = node_modules([
    "@angular-devkit/build-angular",
])

# buildifier: disable=function-docstring
def ng_config(name, **kwargs):
    if name != "ng-config":
        fail("NG config name must be 'ng-config'")

    # Root config files used throughout
    copy_to_bin(
        name = "angular",
        srcs = ["angular.json"],
    )

    # NOTE: project dist directories are under the project dir unlike the Angular CLI default of the root dist folder
    jq(
        name = "tsconfig",
        srcs = ["tsconfig.json"],
        filter = JQ_DIST_REPLACE_TSCONFIG,
    )

    native.filegroup(
        name = name,
        srcs = [":angular", ":tsconfig"],
        **kwargs
    )

def ng_lib(name, project_name = None, deps = [], test_deps = [], **kwargs):
    """
    Bazel macro for compiling an NG library project. Creates {name}, test, targets.

    Args:
      name: the rule name
      project_name: the Angular CLI project name, defaults to current directory name
      deps: dependencies of the library
      test_deps: additional dependencies for tests
      **kwargs: extra args passed to main Angular CLI rules
    """
    srcs = native.glob(
        ["src/**/*"],
        exclude = [
            "src/**/*.spec.ts",
            "src/test.ts",
            "dist/",
        ],
    )

    test_srcs = srcs + native.glob(["src/test.ts", "src/**/*.spec.ts"], allow_empty = True)

    project_name = project_name if project_name else native.package_name().split("/").pop()

    # NOTE: dist directories are under the project dir instead of the Angular CLI default of the root dist folder
    jq(
        name = "ng-package",
        srcs = ["ng-package.json"],
        filter = JQ_DIST_REPLACE_NG_PACKAGE,
        visibility = ["//visibility:private"],
    )

    architect_cli.architect(
        name = "_%s" % name,
        chdir = native.package_name(),
        args = ["%s:build" % project_name],
        out_dirs = ["dist"],
        srcs = srcs + deps + LIBRARY_DEPS + LIBRARY_CONFIG + TOOLS + [COMMON_CONFIG, ":ng-package"],
        visibility = ["//visibility:private"],
        **kwargs
    )

    architect_cli.architect_test(
        name = "test",
        chdir = native.package_name(),
        args = ["%s:test" % project_name, "--no-watch"],
        data = test_srcs + deps + test_deps + TEST_DEPS + TEST_CONFIG + TOOLS + [COMMON_CONFIG, ":ng-package"],
        log_level = "debug",
        **kwargs
    )

    # Output the compiled library and its dependencies
    js_library(
        name = name,
        srcs = [":_%s" % name],
        deps = deps + LIBRARY_DEPS,
    )

def ng_app(name, project_name = None, deps = [], test_deps = [], **kwargs):
    """
    Bazel macro for compiling an NG application project. Creates {name}, test, serve targets.

    Args:
      name: the rule name
      project_name: the Angular CLI project name, to the rule name
      deps: dependencies of the library
      test_deps: additional dependencies for tests
      **kwargs: extra args passed to main Angular CLI rules
    """
    srcs = native.glob(
        ["src/**/*"],
        exclude = [
            "src/**/*.spec.ts",
            "src/test.ts",
            "dist/",
        ],
    )

    test_srcs = native.glob(["src/test.ts", "src/**/*.spec.ts"], allow_empty = True)

    project_name = project_name if project_name else name

    architect_cli.architect(
        name = name,
        chdir = native.package_name(),
        args = ["%s:build" % project_name],
        out_dirs = ["dist/%s" % project_name],
        srcs = srcs + deps + APPLICATION_DEPS + APPLICATION_CONFIG + TOOLS + [COMMON_CONFIG],
        **kwargs
    )

    architect_cli.architect_binary(
        name = "serve",
        chdir = native.package_name(),
        args = ["%s:serve" % project_name],
        data = srcs + deps + APPLICATION_DEPS + APPLICATION_CONFIG + TOOLS + [COMMON_CONFIG],
        **kwargs
    )

    architect_cli.architect_test(
        name = "test",
        chdir = native.package_name(),
        args = ["%s:test" % project_name],
        data = srcs + test_srcs + deps + test_deps + TEST_DEPS + TEST_CONFIG + TOOLS + [COMMON_CONFIG],
        log_level = "debug",
        **kwargs
    )
