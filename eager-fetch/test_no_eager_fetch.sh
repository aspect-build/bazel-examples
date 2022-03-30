#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail

# The external repository we want to avoid fetching
NEGATIVE_REPO="pip_deps"
# Some target pattern we think should *not* require the fetch
TARGETS="//..."

# Create a temporary "clean" output folder
TMP=$(mktemp -d)
bazel --output_base="$TMP" build --symlink_prefix=/ "$TARGETS"

# Assert that the external repository wasn't fetched
[ -e "$TMP/external/$NEGATIVE_REPO" ] && {
    echo >&2 "FAIL: $NEGATIVE_REPO was fetched"
    exit 1
}
