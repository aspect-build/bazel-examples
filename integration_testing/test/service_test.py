import os
import docker
from testcontainers.core.container import DockerContainer

TAR_PATH = os.getenv("TEST_SRCDIR") + "_main/java/src/main/java/com/example/tarball/tarball.tar"
IMAGE_NAME = "aspect.build/java-service:latest"


def _load_latest_tarball():
    """
    testcontainers requires the image already loaded in the daemon, but rules_oci places
    a tar file in bazel-out.
    So, we load the latest tarball to Docker
    So that we run the test against the latest image
    """
    client = docker.from_env()
    with open(TAR_PATH, "rb") as f:
        client.images.load(f)


def test_container_runs():
    _load_latest_tarball()

    user = os.environ["USER"]

    with DockerContainer(
        IMAGE_NAME,
    ).with_bind_ports(
        host=9000,
        container=8080,
    ) as container:
        # get_exposed_port waits for the container to be ready
        # https://github.com/testcontainers/testcontainers-python/blob/2bcb931063e84da1364aa26937778f0e45708000/core/testcontainers/core/container.py#L107-L108
        port = container.get_exposed_port(8080)

        # TODO(alexeagle): have the application inside the container listen on a port so we can use it as a test fixture