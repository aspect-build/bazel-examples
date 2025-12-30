#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

INSTA="$(realpath "$1")"
shift
OUTPUT_SNAPSHOTS_DIR="$1"
shift
SRC_SNAPSHOTS_DIR="$1"
shift
COMMAND="$1"
shift

mkdir -p "${BUILD_WORKSPACE_DIRECTORY}/${SRC_SNAPSHOTS_DIR}"

SNAPSHOT_ARGS=()

# Copy snapshot files to the source tree as `.snap.new` files to work with the insta review tool.
for file in "${OUTPUT_SNAPSHOTS_DIR}"/*; do
    if ! diff $file "$BUILD_WORKSPACE_DIRECTORY/${SRC_SNAPSHOTS_DIR}/$(basename $file)"; then
        cp -f $file "$BUILD_WORKSPACE_DIRECTORY/${SRC_SNAPSHOTS_DIR}/$(basename $file).new"
    fi
    # Keep track of snapshot files to use as a filter so that we only review
    # snapshots for the test rather than every snapshot in the source tree.
    SNAPSHOT_ARGS+=("--snapshot" ${SRC_SNAPSHOTS_DIR}/$(basename $file))
done

# Delete unreferenced snapshots from the source tree, mimicking --unreferenced=delete
# https://insta.rs/docs/advanced/#handling-unused-snapshots
for s in "$BUILD_WORKSPACE_DIRECTORY/${SRC_SNAPSHOTS_DIR}"/*.snap; do
    if [[ ! -f "${OUTPUT_SNAPSHOTS_DIR}/$(basename "$s")" ]]; then
        echo "Removing unused snapshot $s"
        rm "$s"
    fi
done

cd "$BUILD_WORKSPACE_DIRECTORY"
"$INSTA" "${COMMAND}" "${SNAPSHOT_ARGS[@]}"
