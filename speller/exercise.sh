#!/bin/bash
set -e

# This script "exercises" various commands that we expect to run
# without error. More typically these might be coded directly in the
# CI setup, but it is helpful to have them in a script for easy local
# development.
rm -f spell.db

bazel build '...'

# Testing

bazel test //speller/greeting:greeting-test

# Usually most convenient to see output errors inline
bazel test --test_output=errors '...'

# Keep an eye on test execution speed
bazel test '...' --test_verbose_timeout_warnings

# --cache_test_results=no

# Execute the output

# This works, but leaves the data file in the sandbox
bazel run //speller/main:build-dictionary

echo ==================================================================

# Run "spell" via Bazel
bazel run //speller/main about || echo keep_going
bazel run //speller/main somerandomword || echo keep_going

# Run the output "spell" executable; but it will except to find
# its data in the default location it looks for - so we must copy it.
cp bazel-bin/speller/main/spell.db .
bazel-bin/speller/main/spell about || echo keep_going
bazel-bin/speller/main/spell somerandomword || echo keep_going

# Query examples:

bazel query --notool_deps --noimplicit_deps "deps(//speller/main)" --output graph

# To explore interactively
# apt install graphviz xdot
# brew install graphviz xdot
# xdot <(bazel query --notool_deps --noimplicit_deps "deps(//speller/main)"  --output graph)

# Queries to consider:
# What files depend on external dep X?
# what files are referenced by the integration tests?
