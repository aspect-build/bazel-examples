"""Emit a compile-heavy C++ translation unit and its test.

Compile cost comes from template metaprogramming: each generated function
instantiates a binary-branching recursive class template `Node<Tag, N>`. Every
level splits into two children with distinct, prime-perturbed tags, so the
compiler cannot memoize the subtrees away — it must materialize ~2^depth
distinct specializations per function, each with a progressively longer mangled
name. The result (`Node<...>::value`) is a constexpr fold, so it costs the
compiler dearly but the runtime sees only a folded constant.

This makes compile cost SUPERLINEAR in the chosen knobs: roughly linear in
`funcs` and exponential in `tmpl_depth` (each +1 depth ~doubles the work),
while keeping the source file tiny (tens of KB). That is the property the RBE
demo needs — a few hundred KB of source that takes the better part of a minute
of CPU to compile, so a laptop grinds for ~10 min on the whole matrix while RBE
fans the units out in parallel.

Runtime test cost is kept independent of compile cost: `_work` runs a real LCG
loop for `test_iters` iterations, seeded by the (folded) function constants.
So `test_iters` remains the run-cost knob and `funcs`/`tmpl_depth` the
compile-cost knobs. Output is deterministic in (unit, funcs, tmpl_depth).
"""

import argparse


# Recursive, binary-branching class template. Each node at level N expands into
# two children with distinct tags (different prime multipliers), so the two
# subtrees never collapse to the same specialization. `value` is a constexpr
# fold of both children. Specialization at N==0 terminates the recursion.
#
# Portable C++17: no compiler flags, no macOS/clang-only constructs. The
# default -ftemplate-depth (1024) and -fconstexpr-depth (512) comfortably
# accommodate the depths we use (<= ~18), so no flag tuning is required.
_TEMPLATE = """\
template <unsigned long Tag, int N> struct Node {
  static constexpr unsigned long L =
      Node<Tag * 6364136223846793005UL + 1UL, N - 1>::value;
  static constexpr unsigned long R =
      Node<Tag * 2862933555777941757UL + 3UL, N - 1>::value;
  static constexpr unsigned long value = (L ^ (R * 2654435761UL)) + (Tag >> 7);
};
template <unsigned long Tag> struct Node<Tag, 0> {
  static constexpr unsigned long value = Tag | 1UL;
};"""


def emit_lib(unit: str, funcs: int, tmpl_depth: int) -> str:
    parts = [
        "#include <cstdint>",
        f"// generated: unit={unit} funcs={funcs} tmpl_depth={tmpl_depth}",
        _TEMPLATE,
    ]
    for i in range(funcs):
        # Distinct per-function root tag keeps each function's template tree
        # independent (no cross-function memoization), so compile cost scales
        # linearly with `funcs`.
        tag = (i * 2654435761 + 12345) % (1 << 31)
        parts.append(
            f"long {unit}_f{i}(long x) {{\n"
            f"  constexpr unsigned long c = Node<{tag}UL, {tmpl_depth}>::value;\n"
            f"  return (long)c ^ x;\n"
            "}"
        )
    # Runtime work loop: a real LCG mix, seeded by the folded constant of _f0.
    # This is the run-cost path and is INDEPENDENT of the compile-cost template
    # (the template result is a compile-time constant). `test_iters` drives it.
    # Each iteration does several rounds of LCG so per-iteration cost stays
    # substantial even at -O0 (bazel fastbuild), keeping `test_iters` calibrated
    # to ~15s at 200M iters — i.e. the same run-cost meaning as before.
    parts.append(f"long {unit}_work(long iters) {{")
    parts.append(f"  long acc = {unit}_f0(1);")
    parts.append("  for (long i = 0; i < iters; ++i) {")
    parts.append("    for (int j = 0; j < 64; ++j) {")
    parts.append(
        "      acc = (acc * 6364136223846793004L + 1442695040888963407L) ^ (acc >> 31);"
    )
    parts.append("    }")
    parts.append("  }")
    parts.append("  return acc | 1L;")
    parts.append("}")
    return "\n".join(parts) + "\n"


def emit_test(unit: str, iters: int) -> str:
    return (
        "#include <cstdio>\n"
        f"extern long {unit}_work(long iters);\n"
        "int main() {\n"
        f"  long acc = {unit}_work({iters}L);\n"
        '  if (acc == 0) { printf("unexpected zero\\n"); return 1; }\n'
        f'  printf("{unit}: ok (%ld)\\n", acc);\n'
        "  return 0;\n"
        "}\n"
    )


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--unit", required=True)
    p.add_argument("--funcs", type=int, default=400)
    p.add_argument(
        "--tmpl-depth",
        type=int,
        default=14,
        help="recursion depth of the Node<> template (compile-cost knob; "
        "each +1 roughly doubles per-function compile cost)",
    )
    p.add_argument("--test-iters", type=int, default=200_000_000)
    p.add_argument("--lib-out", required=True)
    p.add_argument("--test-out", required=True)
    args = p.parse_args()
    with open(args.lib_out, "w") as f:
        f.write(emit_lib(args.unit, args.funcs, args.tmpl_depth))
    with open(args.test_out, "w") as f:
        f.write(emit_test(args.unit, args.test_iters))


if __name__ == "__main__":
    main()
