# Minimal machine image, intended for hermetic Bazel workloads

# Start with the standard devcontainers base (Ubuntu-based)
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
# Good:
#  direnv for Bazel-managed dev environment
#  curl and ca-certificates for downloading bazelisk
# Bad: non-hermetic deps required to build cruby, needs fixing
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       direnv curl ca-certificates \
       build-essential libssl-dev libyaml-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install bazelisk (latest release)
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 \
      -o /usr/local/bin/bazelisk \
    && chmod +x /usr/local/bin/bazelisk \
    && ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

# Hook direnv into bash (default Codespaces shell)
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc
