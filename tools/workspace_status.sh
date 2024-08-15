#!/usr/bin/env bash
# Produces space-separated key-values for stamp variables.
# Those starting with "STABLE_" will cause actions to re-run when they change.
# See https://docs.aspect.build/rulesets/aspect_bazel_lib/docs/stamping/
set -o errexit -o nounset -o pipefail

git_commit=$(git rev-parse HEAD)

# Follows https://blog.aspect.build/versioning-releases-from-a-monorepo
auto_version=$(
    git describe --tags --long --match="[0-9][0-9][0-9][0-9].[0-9][0-9]" |
        sed -e 's/-/./;s/-g/-/'
)

cat <<EOF
STABLE_GIT_COMMIT ${git_commit}
STABLE_MONOREPO_VERSION ${auto_version}
EOF
