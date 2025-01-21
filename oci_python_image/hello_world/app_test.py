# Loads individual layers from disk by reading their blob locations from
# the OCI format JSON descriptor file.
# TODO: upstream some of this to the testcontainers library to simplify similar code for users.
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs
import docker
import tarfile
import json
import os
import tempfile
import io


def add_json_file(tar, name, contents):
    content = json.dumps(contents).encode("utf-8")
    info = tarfile.TarInfo(name=name)
    info.size = len(content)
    tar.addfile(info, fileobj=io.BytesIO(content))


def add_file(tar, name, fileobj):
    info = tarfile.TarInfo(name=name)
    info.size = os.fstat(fileobj.fileno()).st_size
    tar.addfile(info, fileobj=fileobj)
    fileobj.close()


def get_blob_path(image, digest):
    return "%s/blobs/%s" % (image, digest.replace(":", "/"))


def open_blob(image, digest):
    return open(get_blob_path(image, digest), "rb")


def OCIImageContainer(image):
    with open("%s/index.json" % image) as indexp:
        indexjson = json.load(indexp)

    with open_blob(image, indexjson["manifests"][0]["digest"]) as manifestp:
        manifest = json.load(manifestp)

    with open_blob(image, manifest["config"]["digest"]) as configp:
        config = json.load(configp)

    client = docker.from_env()

    # Probe and layer loading phase
    layers = manifest["layers"]
    needed = []

    
    # Probing phase
    for i, layer in enumerate(layers):
        tmp = tempfile.NamedTemporaryFile(suffix=".tar")
        tar = tarfile.open(fileobj=tmp, mode="w")
        add_json_file(
            tar,
            name="manifest.json",
            contents=[
                {
                    "Config": "config.json",
                    "RepoTags": [],
                    "Layers": [layer['digest']],
                }
            ],
        )
        add_json_file(
            tar,
            name="config.json",
            contents={
                "rootfs": {
                    "type": "layers",
                    "diff_ids": [config["rootfs"]["diff_ids"][i]],
                }
            },
        )

        tar.close()

        try:
            # os.system("tar -tvf %s" % tmp.name)
            client.images.load(
                open(tmp.name, "rb"),
            )
        except docker.errors.ImageLoadError as e:
            needed.append(layer["digest"])

    # Loading phase
    tmp = tempfile.NamedTemporaryFile(suffix=".tar")
    tar = tarfile.open(fileobj=tmp, mode="w")
    add_json_file(
        tar,
        name="manifest.json",
        contents=[
            {
                "Config": "config.json",
                "RepoTags": [],
                "Layers": list(map(lambda x: x["digest"], manifest["layers"])),
            }
        ],
    )
    add_file(
        tar, name="config.json", fileobj=open_blob(image, manifest["config"]["digest"])
    )
    for layer in needed:
        add_file(tar, name=layer, fileobj=open_blob(image, layer))

    tar.close()
    r = client.images.load(open(tmp.name, "rb"))
    return DockerContainer(r[0].id)


def test_wait_for_hello():
    print("Starting container")
    with OCIImageContainer("oci_python_image/hello_world/image") as container:
        wait_for_logs(container, "hello py_image_layer!")


test_wait_for_hello()
