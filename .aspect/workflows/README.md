# Aspect Workflows demonstration deployment

`bazel-examples` is a demonstration deployment of [Aspect Workflows](https://www.aspect.build/workflows) configured to run on Buildkite, CircleCI and GitHub Actions.

You can see this Aspect Workflows demonstration deployment live for each CI host
at the following URLS:

- Buildkite: https://buildkite.com/aspect/bazel-examples
- CircleCI: https://app.circleci.com/pipelines/github/aspect-build/bazel-examples-cci
- GitHub Actions: https://github.com/aspect-build/bazel-examples-gha/actions/workflows/aspect-workflows.yaml
- GitLab: https://gitlab.com/aspect-build/bazel-examples-gl/-/pipelines

## Aspect Workflows configuration yaml

This is the [config.yaml](./config.yaml) file in this directory.

## Buildkite pipeline configuration (in the Buildkite UI)

There are two pipelines configured on Buildkite.

1. Main build & test pipeline: https://buildkite.com/aspect/bazel-examples
2. Scheduled warming pipeline: https://buildkite.com/aspect/bazel-examples-warming

### Main build & test pipeline configuration

The main build & test pipeline found at https://buildkite.com/aspect/bazel-examples is configured
with the following yaml steps:

```
steps:
  - label: ":aspect: Upload .aspect/workflows/buildkite.yaml"
    commands:
      - buildkite-agent pipeline upload .aspect/workflows/buildkite.yaml
    plugins:
      - git-ssh-checkout#v0.4.1
      - sparse-checkout#v1.3.1:
          paths:
            - .aspect
    agents:
      queue: bk-small
```

This uploads the Buildkite pipeline defined in [.aspect/workflows/buildkite.yaml](./buildkite.yaml).

### Scheduled warming pipeline configuration

The scheduled warming pipeline found at https://buildkite.com/aspect/bazel-examples-warming is
configured with the following yaml steps:

```
steps:
  - label: ":fire: Create warming archives"
    commands: |
      echo "--- :aspect-build: Workflows environment"
      /etc/aspect/workflows/bin/configure_workflows_env
      echo "--- :stethoscope: Agent health check"
      /etc/aspect/workflows/bin/agent_health_check
      echo "--- :bazel: Create warming archive for ."
      rosetta run warming
      /etc/aspect/workflows/bin/warming_archive
    agents:
      queue: aspect-warming
```

The warming pipeline is not configured to trigger on commits or PRs. Instead, it is triggered
by a Buildkite pipeline schedule with the cron interval `0 1 * * 1-5 America/Los_Angeles`. It
runs nightly on weekdays to create up-to-date warming archives containing cached external repositories.
The most recent warming archive is restored during bootstrap of the "default" runner group to speed up
the first build on cold runners.

## GitHub Actions pipeline configuration

1.  [.github/workflows/aspect-workflows.yaml](../../.github/workflows/aspect-workflows.yaml) : Aspect Workflows CI workflow

1.  [.github/workflows/aspect-workflows-warming.yaml](../../.github/workflows/aspect-workflows-warming.yaml) : Aspect Workflows warming cron workflow

## CircleCI pipeline configuration

The CircleCI pipeline is defined in [.circleci/config.yml](../../.circleci/config.yml).

## GitLab pipeline configuration

The GitLab pipeline is defined in [.gitlab-ci.yml](../../.gitlab-ci.yml).