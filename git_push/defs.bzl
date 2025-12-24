"git_push rule for delivering to GitHub"

load("@bazel_lib//lib:expand_template.bzl", "expand_template")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

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
        template = Label(":push_archive_to_repo.sh"),
        # See /.bazelrc which includes a --workspace_status_command
        stamp_substitutions = {"0.0.0-PLACEHOLDER": "{{BUILD_VERSION}}"},
    )

    sh_binary(
        name = name,
        srcs = [stamped],
        data = [archive],
        args = ["$(rootpath {})".format(archive), repo_url],
        **kwargs
    )
