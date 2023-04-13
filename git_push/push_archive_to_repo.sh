#!/usr/bin/env bash
# Executable that unpacks an archive, and pushes the content as a git repo
# Assumes that `git` is on the machine and has push credentials already.
# Inspired from how Angular publishes snapshots to "*-build" repos:
# https://github.com/angular/angular/blob/main/scripts/ci/publish-build-artifacts.sh
#
# Caveats:
# - Not hermetic: uses the system `tar` and `mktemp` utilities
# - Needs a Personal Access Token for performing the push from CI, see MYORG_GHBOT_PAT below.
set -o errexit -o nounset -o pipefail

ARCHIVE=$1
REPO_URL=$2
REPO_DIR=$(mktemp -d)

# CircleCI has a config setting to force SSH for all github connections
# This is not compatible with "machine accounts" using a Personal Access Token
# Clear the global setting.
if [[ ${CI:-} ]]; then
    git config --global --unset "url.ssh://git@github.com.insteadof"
fi

git clone "$REPO_URL" "$REPO_DIR" --depth 1
# Unshallow the repo manually so that it doesn't trigger a push failure.
# This is generally unsafe, however we immediately remove all of the files from within
# the repo on the next line, so we should be able to safely treat the entire repo
# contents as an atomic piece to be pushed.
rm "$REPO_DIR/.git/shallow"

# copy over build artifacts into the repo directory
rm -rf "${REPO_DIR:?}/*"
tar -xvf "$ARCHIVE" -C "$REPO_DIR"

(
    cd "$BUILD_WORKSPACE_DIRECTORY"
    COMMITTER_USER_NAME=$(git --no-pager show -s --format='%cN' HEAD)
    COMMITTER_USER_EMAIL=$(git --no-pager show -s --format='%cE' HEAD)
    # Don't disclose our internal commit messages
    COMMIT_MSG="Sync internal change to GitHub"
    BRANCH=main

    cd "$REPO_DIR"

    if [[ ${CI:-} ]]; then
        # Stash some credentials from a personal access token saved in the GitHub Actions secrets.
        # You'll need to adjust this for how you want to pass your GitHub token through your CI
        # system's secret management.
        echo "https://${MYORG_GHBOT_PAT}:@github.com" > "$HOME/.git_credentials"
        git config credential.helper store
    fi

    # Mirror the committer info so we know who performed the relevant changes.
    git config user.name "${COMMITTER_USER_NAME}" \
        && git config user.email "${COMMITTER_USER_EMAIL}" \
        && git add --all \
        && git commit -m "${COMMIT_MSG}" --quiet \
        && git tag "0.0.0-PLACEHOLDER" --force \
        && git push origin "${BRANCH}" --force --tags
)
