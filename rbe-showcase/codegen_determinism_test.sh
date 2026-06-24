#!/usr/bin/env bash
# Generated sources must be byte-identical across runs — cache-friendliness
# of the whole matrix depends on it.
set -euo pipefail
CODEGEN="rbe-showcase/codegen"
"$CODEGEN" --unit det --funcs 5 --test-iters 100 --lib-out a.cc --test-out a_test.cc
"$CODEGEN" --unit det --funcs 5 --test-iters 100 --lib-out b.cc --test-out b_test.cc
diff a.cc b.cc
diff a_test.cc b_test.cc
echo "deterministic: ok"
