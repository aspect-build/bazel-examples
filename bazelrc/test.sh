#!/usr/bin/env bash
set -o nounset -o errexit -o pipefail

set -o xtrace
bazel clean --expunge --bazelrc=.aspect/bazelrc/ci.bazelrc
bazel build ... --bazelrc=.aspect/bazelrc/ci.bazelrc
bazel test ... --bazelrc=.aspect/bazelrc/ci.bazelrc
bazel query ... --bazelrc=.aspect/bazelrc/ci.bazelrc
bazel fetch ... --bazelrc=.aspect/bazelrc/ci.bazelrc
