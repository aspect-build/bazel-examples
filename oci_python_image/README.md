# Example of Python plus rules_oci

There are a couple ways to treat the interpreter:

1. Choose a base image which includes it. This is the typical approach outside Bazel, and is
    recommended when migrating from a Dockerfile or similar build system to avoid changing
    multiple things at the same time. In `/MODULE.bazel` we use `oci.pull` to pull https://hub.docker.com/_/python and then in `use_python_base/BUILD.bazel` we choose that as the base image. Then, the Bazel-built Python application just falls through to the "system interpreter".
2. Propagate Bazel's "toolchain resolution" so that the same interpreter used by `bazel run` 
    will also be used when the Python application runs in a container. This avoids version skew in the Python version used. In `/MODULE.bazel` we use `oci.pull` to pull the Distroless base image (which is tiny). Then the `interpreter_as_layer/BUILD.bazel` file shows how we get that interpreter as a layer in the image.
