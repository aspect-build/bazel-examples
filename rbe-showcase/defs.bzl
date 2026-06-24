"""rbe_matrix: a wide, shallow matrix of compile-heavy compile + test targets.

Demonstrates RBE fan-out: every unit is independent, so remote execution
parallelizes the whole matrix while a laptop grinds through it serially.
Sizing knobs:
  count        number of independent units
  funcs        functions per unit (linear compile-cost knob)
  tmpl_depth   Node<> template recursion depth (superlinear compile-cost knob;
               each +1 roughly doubles per-function compile cost)
  test_iters   LCG iterations per test (runtime cost/test knob)
See README.md for sizing guidance and target timings.

Every generated target is tagged `manual` so the matrix is excluded from
wildcard patterns (`//...`). That keeps it out of the repo's CI test run and
out of a casual local `bazel test //...` (compiling hundreds of these units at
once is memory-hungry — see README.md). Run the demo explicitly via the
generated `<name>` test_suite, e.g.:

    bazel test --config=rbe //rbe-showcase:matrix
"""

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")

# Tag applied to every generated target so it is skipped by wildcard target
# patterns (`//...`, `//rbe-showcase/...`). Demo runs name the test_suite
# explicitly, which bypasses the wildcard exclusion.
_MANUAL = ["manual"]

def rbe_matrix(name, count = 150, funcs = 400, tmpl_depth = 14, test_iters = 200000000):
    """Stamp out `count` independent compile-heavy cc_library + cc_test units.

    All generated targets are tagged `manual`; run the demo via the generated
    `name` test_suite (see the module docstring).

    Args:
      name: base name; also the name of the generated test_suite.
      count: number of independent compile + test units.
      funcs: template functions per unit (linear compile-cost knob).
      tmpl_depth: Node<> recursion depth (superlinear compile-cost knob; each
        +1 roughly doubles per-function compile cost and peak RSS).
      test_iters: LCG iterations per test (runtime cost-per-test knob).
    """
    units = []
    tests = []
    for i in range(count):
        # Starlark doesn't support zero-padding via %03d; format manually.
        suffix = str(i)
        if i < 10:
            suffix = "00" + suffix
        elif i < 100:
            suffix = "0" + suffix
        unit = "%s_u%s" % (name, suffix)
        native.genrule(
            name = unit + "_srcs",
            outs = [unit + ".cc", unit + "_test.cc"],
            cmd = "$(location //rbe-showcase:codegen) --unit {unit} --funcs {funcs} --tmpl-depth {depth} --test-iters {iters} --lib-out $(location {unit}.cc) --test-out $(location {unit}_test.cc)".format(
                unit = unit,
                funcs = funcs,
                depth = tmpl_depth,
                iters = test_iters,
            ),
            tools = ["//rbe-showcase:codegen"],
            tags = _MANUAL,
        )
        cc_library(
            name = unit,
            srcs = [unit + ".cc"],
            tags = _MANUAL,
        )
        cc_test(
            name = unit + "_test",
            size = "medium",
            srcs = [unit + "_test.cc"],
            deps = [":" + unit],
            tags = _MANUAL,
        )
        units.append(unit)
        tests.append(":" + unit + "_test")

    # Explicit demo entry point. Tagged `manual` so `//...` skips it; naming it
    # directly (`bazel test //rbe-showcase:<name>`) runs every unit test in the
    # matrix because the `tests` attribute references them explicitly.
    native.test_suite(
        name = name,
        tests = tests,
        tags = _MANUAL,
    )
