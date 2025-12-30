#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

SED="$1"
shift
SNAPSHOTS_DIR="$1"
shift
OUTPUT_DIR="$1"
shift
PREFIX="$1"
shift

for snapshot in "${SNAPSHOTS_DIR}"/*; do
    snapshot_relative="${snapshot#"$PREFIX"}"
    "${SED}" <"${snapshot}" "s/\(source: \).*\$/\1${snapshot_relative//\//\\\/}/" > "${OUTPUT_DIR}/$(basename "$snapshot")"
done
