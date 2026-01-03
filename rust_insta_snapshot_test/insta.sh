#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

INSTA="$1"
shift
OUTPUT_SNAPSHOTS_DIR="$1"
shift
SRC_SNAPSHOTS_DIR="$1"
shift
COMMAND="$1"
shift

INSTA_PENDING_DIR="${OUTPUT_SNAPSHOTS_DIR}" "$INSTA" "${COMMAND}" --workspace-root "${BUILD_WORKSPACE_DIRECTORY}"
