#!/bin/bash

set -e

# Run the overall tests and then run the Speller-specific C++ testing.

bazel \
--bazelrc=$GITHUB_WORKSPACE/.aspect/bazelrc/ci.bazelrc \
--bazelrc=$GITHUB_WORKSPACE/.github/workflows/ci.bazelrc \
test //...

cd speller
./exercise.sh
