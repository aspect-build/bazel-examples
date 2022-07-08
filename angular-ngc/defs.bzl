load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@aspect_rules_js//npm:defs.bzl", "npm_package")
load("@aspect_rules_ts//ts:defs.bzl", _ts_project = "ts_project")
load("@aspect_rules_esbuild//esbuild:defs.bzl", "esbuild")
load("@npm//:karma/package_json.bzl", _karma_bin = "bin")
load(":karma.bzl", "generate_karma_config")

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

TEST_DEPS = APPLICATION_DEPS + [
    "//:node_modules/@angular/compiler",
    "//:node_modules/@types/jasmine",
    "//:node_modules/jasmine-core",
    "//:node_modules/@angular/platform-browser-dynamic",
]

# Common dependencies of Angular test suites using jasmine
TEST_RUNNER_DEPS = TEST_DEPS + [
    "//:node_modules/karma-chrome-launcher",
    "//:node_modules/karma",
    "//:node_modules/karma-jasmine",
    "//:node_modules/karma-jasmine-html-reporter",
    "//:node_modules/karma-coverage",
]

def ts_project(name, **kwargs):
    _ts_project(
        name = name,

        # Default tsconfig and aligning attributes
        tsconfig = kwargs.pop("tsconfig", "//:tsconfig"),
        declaration = kwargs.pop("declaration", True),
        declaration_map = kwargs.pop("declaration_map", True),
        source_map = kwargs.pop("source_map", True),
        **kwargs
    )

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

def ng_application(name, deps = [], test_deps = [], **kwargs):
    """
    Bazel macro for compiling an NG application project. Creates {name}, test, serve targets.

    Args:
      name: the rule name
      deps: dependencies of the library
      test_deps: additional dependencies for tests
      **kwargs: extra args passed to main Angular CLI rules
    """
    test_spec_srcs = native.glob(["src/**/*.spec.ts"])

    srcs = native.glob(
        ["app/**/*"],
        exclude = test_spec_srcs,
    )

    ng_project(
        name = "_app",
        srcs = srcs,
        deps = deps + APPLICATION_DEPS,
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

    test_entry_point = native.glob(["src/test.ts"])
    test_spec_srcs = native.glob(["src/**/*.spec.ts"])

    srcs = native.glob(
        ["src/**/*.ts", "src/**/*.css", "src/**/*.html"],
        exclude = test_spec_srcs + test_entry_point,
    )

    ng_project(
        name = "_lib",
        srcs = srcs,
        deps = deps + LIBRARY_DEPS,
        visibility = ["//visibility:private"],
    )

    # A package.json pointing to the public_api.js as the package entry point
    # TODO: TBD: could also write an index.js file, or drop the public_api.ts convention for index.ts
    write_file(
        name = "_package_json",
        out = "package.json",
        content = ["""{"name": "%s", "main": "./public-api.js", "types": "./public-api.d.ts"}""" % package_name],
        visibility = ["//visibility:private"],
    )

    # Output the library as an npm package that can be linked.
    npm_package(
        name = "_pkg",
        package = package_name,
        root_paths = [
            native.package_name(),
            "%s/src" % native.package_name(),
        ],
        srcs = [":_lib", ":_package_json"],
        visibility = ["//visibility:private"],
    )

    # The primary public library target. Aliased to allow "_pkg" as the npm_package()
    # name and therefore also output directory.
    native.alias(
        name = name,
        actual = "_pkg",
        visibility = visibility,
    )

    if len(test_spec_srcs) > 0:
        ng_project(
            name = "_tests",
            srcs = test_spec_srcs + test_entry_point,
            deps = [":_lib"] + test_deps + TEST_DEPS,
            testonly = 1,
            visibility = ["//visibility:private"],
        )

        # Bundle the spec files
        esbuild(
            name = "_test_bundle",
            testonly = 1,
            entry_points = [spec.replace(".ts", ".js") for spec in test_spec_srcs + test_entry_point],
            deps = [":_tests"],
            output_dir = True,
            splitting = True,
            visibility = ["//visibility:private"],
        )

        karma_config_name = "%s.conf" % name
        generate_karma_config(
            name = karma_config_name,
            bundle = "_test_bundle",
            bootstrap = [],
            static_files = [],
            specs = [":_test_bundle"],
            testonly = 1,
        )

        _karma_bin.karma_test(
            name = "_karma_test",
            testonly = 1,
            data = [":%s" % karma_config_name, ":_test_bundle"] + TEST_RUNNER_DEPS,
            args = [
                "start",
                "$(rootpath %s)" % karma_config_name,
            ],
        )
