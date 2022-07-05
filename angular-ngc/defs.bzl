load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@aspect_rules_js//npm:defs.bzl", "npm_package")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@aspect_rules_esbuild//esbuild:defs.bzl", "esbuild")

# Common dependencies of Angular applications
APPLICATION_DEPS = [
    "//:node_modules/@angular/common",
    "//:node_modules/@angular/core",
    "//:node_modules/@angular/router",
    "//:node_modules/@angular/platform-browser",
    "//:node_modules/rxjs",
    "//:node_modules/tslib",
    "//:node_modules/zone.js",
]

# Common dependencies of Angular libraries
LIBRARY_DEPS = [
    "//:node_modules/@angular/common",
    "//:node_modules/@angular/core",
    "//:node_modules/@angular/router",
    "//:node_modules/rxjs",
    "//:node_modules/tslib",
]

# Common dependencies of Angular test suites using jasmine
TEST_CONFIG = [
    "//:karma.conf.js",
    "//:node_modules/@types/jasmine",
    "//:node_modules/karma-chrome-launcher",
    "//:node_modules/karma",
    "//:node_modules/karma-jasmine",
    "//:node_modules/karma-jasmine-html-reporter",
    "//:node_modules/karma-coverage",
]
TEST_DEPS = APPLICATION_DEPS + [
    "//:node_modules/@angular/compiler",
    "//:node_modules/@types/jasmine",
    "//:node_modules/jasmine-core",
]

def ng_project(name, **kwargs):
    """The rules_js ts_project() configured with the Angular ngc compiler.
    """
    ts_project(
        name = name,

        # Compiler
        tsc = "//:ngc",
        supports_workers = False,

        # Any other ts_project() or generic args
        **kwargs
    )

def ng_application(name, project_name = None, deps = [], test_deps = [], **kwargs):
    """
    Bazel macro for compiling an NG application project. Creates {name}, test, serve targets.

    Args:
      name: the rule name
      project_name: the Angular CLI project name, to the rule name
      deps: dependencies of the library
      test_deps: additional dependencies for tests
      **kwargs: extra args passed to main Angular CLI rules
    """
    test_srcs = native.glob(["src/**/*.spec.ts"])

    srcs = native.glob(
        ["src/**/*"],
        exclude = test_srcs,
    )

    ng_project(
        name = "_%s" % name,
    )

def ng_library(name, package_name, deps = [], test_deps = [], visibility = ["//visibility:public"]):
    """
    Bazel macro for compiling an NG library project. Creates {name} and test targets.

    Projects structure:
      src:
        public_api.ts
        **/*.{ts,css,html}

    Tests:
      src:
        **/*.spec.ts

    Args:
      name: the rule name
      package_name: the package name
      deps: dependencies of the library
      test_deps: additional dependencies for tests
      visibility: visibility of the primary targets ({name}, 'test')
    """

    test_srcs = native.glob(["src/**/*.spec.ts"])

    srcs = native.glob(
        ["src/**/*.ts", "src/**/*.css", "src/**/*.html"],
        exclude = test_srcs,
    )

    ng_project(
        name = "_%s" % name,
        srcs = srcs,
        deps = deps + LIBRARY_DEPS,
        tsconfig = {
            "compilerOptions": {
                "declaration": True,
                "declarationMap": True,
                "outDir": "_dist",
            },
        },
        extends = "//:tsconfig",
        visibility = ["//visibility:private"],
    )

    # A package.json pointing to the public_api.js as the package entry point
    # TODO: TBD: could also write an index.js file, or drop the public_api.ts convention for index.ts
    write_file(
        name = "_%s_package_json" % name,
        out = "_dist/package.json",
        content = ["""{"name": "%s", "main": "./public_api.js", "types": "./public-api.d.ts"}""" % package_name],
        visibility = ["//visibility:private"],
    )

    # Output the library as an npm package that can be linked.
    npm_package(
        name = "_pkg",
        package = package_name,
        root_paths = [native.package_name(), "%s/_dist" % native.package_name(), "%s/_dist/src" % native.package_name()],
        srcs = [":_%s" % name, "_%s_package_json" % name],
        visibility = ["//visibility:private"],
    )

    # The primary public library target. Aliased to allow "_pkg" as the npm_package()
    # name and therefore also output directory.
    native.alias(
        name = name,
        actual = "_pkg",
        visibility = visibility,
    )

    if len(test_srcs) > 0:
        ng_project(
            name = "_%s_tests" % name,
            srcs = test_srcs,
            deps = [":_%s" % name] + test_deps + TEST_DEPS,
            tsconfig = {
                "compilerOptions": {
                    "declaration": False,
                    "declarationMap": False,
                    "outDir": "_test",
                    "rootDirs": [
                        ".",
                        "_dist",
                    ],
                },
            },
            testonly = 1,
            extends = "//:tsconfig",
            visibility = ["//visibility:private"],
        )

        bundle_name = "%s_tests.bundle" % name
        esbuild(
            name = bundle_name,
            testonly = 1,
            deps = [":_%s_tests" % name],
            entry_points = [":_%s_tests" % name],
        )
