"Macro definitions to make shorter BUILD files for calling Angular CLI via the architect subsystem"

load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_to_bin")
load("@aspect_bazel_lib//lib:jq.bzl", "jq")
load("@aspect_rules_js//js:defs.bzl", "js_library")
load("@npm//angular19:@angular-devkit/architect-cli/package_json.bzl", architect_cli = "bin")

# JQ expressions to update Angular project output paths from dist/* to projects/*/dist
# We do this to avoid mutating the files in the source tree, so that the native tooling without Bazel continues to work.
JQ_DIST_REPLACE_TSCONFIG = """
    .compilerOptions.paths |= map_values(
      map(
        gsub("^dist/(?<p>.+)$"; "projects/"+.p+"/dist")
      )
    )
"""
JQ_DIST_REPLACE_NG_PACKAGE = """.dest = "dist" """

# Minor syntax sugar
def node_modules(pkgs):
    return ["//angular19:node_modules/" + s for s in pkgs]

TEST_PATTERNS = [
    "src/**/*.spec.ts",
    "src/test.ts",
    "dist/",
]

# Idiomatic configuration files created by `ng generate`
TEST_CONFIG = [
    ":tsconfig.spec.json",
]

# Common dependencies of Angular CLI libraries
LIBRARY_CONFIG = [
    ":tsconfig.lib.json",
    ":tsconfig.lib.prod.json",
    ":package.json",
]

APPLICATION_CONFIG = [
    ":tsconfig.app.json",
]

# Typical dependencies of angular apps
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

LIBRARY_DEPS = node_modules([
    "@angular/common",
    "@angular/core",
    "@angular/router",
    "rxjs",
    "tslib",
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

def ng_library(name, project_name = None, deps = [], ng_config = "//angular19:ng-config", **kwargs):
    """
    Bazel macro for compiling an NG library project that was produced by 'ng generate library'.

    Args:
      name: the rule name
      project_name: the Angular CLI project name, defaults to current directory name
      deps: dependencies of the library
      ng_config: root configurations (angular.json, tsconfig.json)
      **kwargs: extra args passed to main Angular CLI rules
    """
    srcs = native.glob(["src/**/*"], exclude = TEST_PATTERNS)

    project_name = project_name or native.package_name().split("/").pop()

    # NOTE: dist directories are under the project dir instead of the Angular CLI default of the root dist folder
    jq(
        name = "ng-package",  # outputs ng-package.json. Can only have one per package.
        srcs = ["ng-package.json"],
        filter = JQ_DIST_REPLACE_NG_PACKAGE,
        visibility = ["//visibility:private"],
    )

    architect_cli.architect(
        name = "%s.build" % name,
        chdir = native.package_name(),
        args = ["%s:build" % project_name],
        out_dirs = ["dist"],
        srcs = srcs + deps + LIBRARY_DEPS + LIBRARY_CONFIG + TOOLS + [ng_config, "ng-package"],
        visibility = ["//visibility:private"],
        **kwargs
    )

    # Output the compiled library and its dependencies
    js_library(
        name = name,
        srcs = [":%s.build" % name],
        deps = deps + LIBRARY_DEPS,
    )

def ng_test(name, project_name = None, deps = [], ng_config = "//angular19:ng-config", **kwargs):
    """
    Bazel macro for compiling an NG library project.

    Args:
      name: the rule name
      project_name: the Angular CLI project name, defaults to current directory name
      deps: additional dependencies for tests
      ng_config: root configurations (angular.json, tsconfig.json)
      **kwargs: extra args passed to main Angular CLI rules
    """
    srcs = native.glob(["src/**/*"], exclude = ["dist/"])

    project_name = project_name if project_name else native.package_name().split("/").pop()

    architect_cli.architect_test(
        name = name,
        chdir = native.package_name(),
        args = ["%s:test" % project_name, "--no-watch"],
        data = srcs + deps + TEST_DEPS + TEST_CONFIG + TOOLS + [ng_config, ":ng-package"],
        log_level = "debug",
        **kwargs
    )

def ng_application(name, project_name = None, deps = [], **kwargs):
    """
    Bazel macro for compiling an NG application project. Creates {name}, {name}.serve targets.

    Args:
      name: the rule name
      project_name: the Angular CLI project name, to the rule name
      deps: dependencies of the application, typically ng_library rules
      **kwargs: extra args passed to main Angular CLI rules
    """
    srcs = native.glob(["src/**/*"], exclude = TEST_PATTERNS)

    project_name = project_name if project_name else name

    architect_cli.architect(
        name = name,
        chdir = native.package_name(),
        args = ["%s:build" % project_name],
        out_dirs = ["dist/%s" % project_name],
        srcs = srcs + deps + APPLICATION_DEPS + APPLICATION_CONFIG + TOOLS,
        **kwargs
    )

    architect_cli.architect_binary(
        name = name + ".serve",
        chdir = native.package_name(),
        args = ["%s:serve" % project_name],
        data = srcs + deps + APPLICATION_DEPS + APPLICATION_CONFIG + TOOLS,
        **kwargs
    )
