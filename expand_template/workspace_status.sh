#!/bin/bash
# This script is called by Bazel when it needs info about the git state.
# The --workspace_status_command flag tells Bazel the location of this script.
# This is configured in `/.bazelrc`.
set -o pipefail -o errexit -o nounset

function has_local_changes {
    if [ "$(git status --porcelain)" != "" ]; then
        echo dirty
    else
        echo clean
    fi
}

# "volatile" keys, these will not cause a re-build because they're assumed to change on every build
# and its okay to use a stale value in a stamped binary
echo "BUILD_TIME $(date "+%Y-%m-%d %H:%M:%S %Z")"

# "stable" keys, should remain constant over rebuilds, therefore changed values will cause a
# rebuild of any stamped action that uses ctx.info_file or genrule with stamp = True
# Note, BUILD_USER is automatically available in the stable-status.txt, it matches $USER
echo "STABLE_BUILD_SCM_SHA $(git rev-parse HEAD)"
echo "STABLE_BUILD_SCM_LOCAL_CHANGES $(has_local_changes)"

# For demonstration, STABLE_BUILD_SCM_TAG is hard-coded to 1.2.3. Typically you would set this to
# the output of `git describe --tags` or use a program such as https://github.com/choffmeister/git-describe-semver
# to produce a semver compliant version. Alex's blog post, https://blog.aspect.dev/versioning-releases-from-a-monorepo,
# describes an alternative monorepo versioning scheme.
echo "STABLE_BUILD_SCM_TAG 1.2.3"
