"git_push rule for delivering to GitHub"

# We can't use the bazel-lib one, because it doesn't have a program to read stamp vars.
# see https://github.com/aspect-build/rules_js/pull/384#issue-1337742941
# load("@aspect_bazel_lib//lib:expand_make_vars.bzl", "expand_template")
# buildifier: disable=bzl-visibility
load("@aspect_rules_js//js/private:expand_template.bzl", "expand_template")

def git_push(name, archive, repo_url, **kwargs):
    """Push a commit to the given git remote, replacing the repo content with the content of the archive.

    Args:
        name: unique name of the runnable sh_binary target
        archive: a tar file
        repo_url: a git remote url; the machine needs credentials to be able to push
        **kwargs: additional named arguments to sh_binary
    """
    if not archive.endswith(".tar"):
        fail("only handles tar files currently")
    if not repo_url.startswith("https://"):
        fail("Continuous delivery with a GitHub Personal Access Token works only with HTTPS urls")

    stamped = "_{}_push_archive_to_repo.stamped.sh".format(name)
    expand_template(
        name = "stamp_pusher",
        out = stamped,
        template = "//:push_archive_to_repo.sh",
        stamp_substitutions = {"0.0.0-PLACEHOLDER": "{{BUILD_VERSION}}"},
    )

    native.sh_binary(
        name = name,
        srcs = [stamped],
        data = [archive],
        args = ["$(rootpath {})".format(archive), repo_url],
        **kwargs
    )
