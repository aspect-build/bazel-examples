# git_push example

This shows how you can make an executable rule that publishes a subset of `bazel-out` to a GitHub repository.

This is useful when your monorepo wants to export some package, for example an SDK for your APIs.

Aspect uses this ourselves to publish our workflows packages from our internal monorepo, for example https://github.com/aspect-build/workflows-action comes from one folder in our repo.

To use this, you just `bazel run --stamp :push` and it will push commits, and tag the remote repo.

Since this is a Bazel executable target, you could also continuously deliver it using Aspect Workflows, see
<https://docs.aspect.build/v/workflows/delivery>
