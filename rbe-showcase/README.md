# RBE showcase

A wide, shallow matrix of independent, compile-heavy C++ build + test units,
designed to make the difference between local execution and
[Remote Build Execution (RBE)](https://aspect.build/docs/cli/remote-execution)
obvious in a single command.

Every unit is independent, so RBE fans the whole matrix out across remote
workers in parallel while a single laptop has to grind through it serially. The
work is real compiler work — not a `sleep` — so the timings reflect what RBE
does for a genuinely expensive build.

## How it works

`codegen.py` emits a tiny (tens of KB) C++ translation unit whose compile cost
is dominated by template metaprogramming: each generated function instantiates a
binary-branching recursive class template `Node<Tag, N>`. Every level forks into
two children with distinct, prime-perturbed tags, so the compiler cannot memoize
subtrees — it must materialize ~2^`tmpl_depth` distinct specializations per
function. The result is a `constexpr` fold, so the cost lands entirely on the
compiler; the runtime sees a folded constant.

This makes compile cost **superlinear** in the knobs — roughly linear in `funcs`
and exponential in `tmpl_depth` — while keeping each source file small. Test
runtime is a separate, CPU-bound LCG loop driven by `test_iters`, independent of
compile cost, so the two costs can be tuned separately.

`rbe_matrix` (see [`defs.bzl`](./defs.bzl)) stamps out `count` copies of this
unit as independent `cc_library` + `cc_test` pairs.

## Running it

The matrix targets are all tagged `manual`, so they are **excluded from
`//...`** — neither the repo's CI nor a casual `bazel test //...` will pull them
in (compiling hundreds of these at once is memory-hungry; see below). Run the
demo by naming the `matrix` test_suite explicitly.

Locally (serial — slow, the "before"):

```sh
bazel test //rbe-showcase:matrix
```

On RBE (fanned out — fast, the "after"):

```sh
bazel test --config=rbe //rbe-showcase:matrix
```

The codegen itself has a fast, CI-safe determinism check (generated sources must
be byte-identical across runs for the matrix to be cache-friendly):

```sh
bazel test //rbe-showcase:codegen_determinism_test
```

## Knobs

Set in [`BUILD.bazel`](./BUILD.bazel) via the `rbe_matrix(...)` call:

| knob         | default   | meaning |
|--------------|-----------|---------|
| `count`      | 200       | independent compile + test units in the matrix |
| `funcs`      | 200       | template functions per unit (linear compile cost **and** RSS) |
| `tmpl_depth` | 9         | `Node<>` recursion depth (each +1 ≈ doubles compile cost **and** RSS) |
| `test_iters` | 200000000 | LCG iterations per test (~16 s/test; runtime knob, memory-trivial) |

`tmpl_depth` stays well under the default `-ftemplate-depth` / `-fconstexpr-depth`
limits, so no compiler flags are required — plain, portable C++17.

## ⚠️ Sizing is memory-constrained, not just CPU

Compile cost is capped by compiler **memory**, not CPU. The compiler retains the
AST for every template specialization for the whole translation unit, so RSS
scales with instantiation count the same way CPU does — roughly **~2 s CPU per
~1 GB peak RSS** near these defaults, and it grows ~2× for every `+1` of
`tmpl_depth`. Bazel then multiplies per-unit RSS by `--jobs` (defaults to your
core count), so peak local build memory is approximately
`RSS-per-unit × jobs`.

At the defaults above (`tmpl_depth = 9`, ≈0.8 GB/unit) an 18-core machine peaks
around 14 GB during the build phase — fine. **Do not raise `tmpl_depth` or
`funcs` without first measuring a single unit** (e.g. with `/usr/bin/time -l`)
and multiplying peak RSS by your core count: a couple of depth steps higher is
enough to exhaust a laptop's RAM. If you're demoing with a browser or video call
open, throttle the build with `--jobs=8`.

## Approximate timings

Illustrative, at the defaults (`count = 200`, `funcs = 200`, `tmpl_depth = 9`):

| environment                  | wall time (cold) |
|------------------------------|------------------|
| 18-core workstation, local   | ~3–4 min         |
| typical 4-core laptop, local | ~15 min          |
| RBE, warm cache              | < 1 min          |

The RBE win comes from fan-out: the whole matrix executes across many remote
workers concurrently, while a single machine is bounded by its core count.
