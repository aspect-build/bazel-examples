# Loads individual layers from disk by reading their blob locations from
# the OCI format JSON descriptor file.
# TODO: upstream some of this to the testcontainers library to simplify similar code for users.
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs
import logging

# This function is self container for easy-to-use by just copy-pasting. 
def OCIImageContainer(image):
    import docker
    import tarfile
    import json
    import os
    import io
    import logging
    import hashlib

    logger = logging.getLogger("incremental_loader")
    def tar(*args):
        buffer = io.BytesIO()
        with tarfile.open(fileobj=buffer, mode="w:") as t:
            for name, size, contents in args:
                info = tarfile.TarInfo(name=name)
                info.size = size
                if isinstance(contents, list) or isinstance(contents, dict):
                    content = json.dumps(contents).encode("utf-8")
                    info.size = len(content)
                    contents = io.BytesIO(content)
    
                t.addfile(info, fileobj=contents)
                contents.close()
        return buffer

    def config_json(diff_ids):
        return ("config.json", None, {
            "rootfs": {
                "type": "layers",
                "diff_ids": diff_ids
            }
        })
    
    def manifest_json(layers):
        return ("manifest.json", None, [{
            "Config": "config.json",
            "RepoTags": [],
            "Layers": layers
        }])


    def open_blob(image, digest):
        blob_path = "%s/blobs/%s" % (image, digest.replace(":", "/"))
        return open(blob_path, "rb")

    with open("%s/index.json" % image) as indexp:
        indexjson = json.load(indexp)

    with open_blob(image, indexjson["manifests"][0]["digest"]) as manifestp:
        manifest = json.load(manifestp)

    with open_blob(image, manifest["config"]["digest"]) as configp:
        config = json.load(configp)

    client = docker.from_env()

    # Happy path: check if the image exists in the cache
    try:
        probe = tar(
            manifest_json(layers=[layer["digest"] + ".tar" for layer in manifest["layers"]]),
            ("config.json", manifest["config"]["size"], open_blob(image, manifest["config"]["digest"]))
        )
        client.images.load(probe.getvalue())
        logger.debug("Image was a cache hit")
        return DockerContainer(manifest["config"]["digest"])
    except docker.errors.ImageLoadError as e:
        logger.debug("Image was a cache miss because %s" % e)

    
    # Unhappy path: image is not in the cache, so we need to load it incrementally
    layers = manifest["layers"]
    start_from = 0

    # Probe the cache for the first layer that is not in the cache
    for i in range(1, len(layers)):
        previous_layer = layers[i-1]
        layer = layers[i]

        probe = tar(
            manifest_json(layers=[layer["digest"] + ".tar" for layer in manifest["layers"][:i]]),
            config_json(diff_ids=config["rootfs"]["diff_ids"][:i])
        )
    
        try:
            probe_res = client.images.load(probe.getvalue())
            logger.debug("Layer %s was a cache hit" % layer["digest"], probe_res[0].id)
        except docker.errors.ImageLoadError as e:
            logger.debug("Layer %s was a cache miss because %s" % (layer["digest"], e))
            # From this point on we need to load everything.
            start_from = i-1
            break

    logger.debug("Need to load all the layers after: ", start_from)

    # Load all layers at once
    load = tar(
        # Send only needed layers
        *[(layer["digest"] + ".tar", layer["size"], open_blob(image, layer["digest"])) for layer in layers[start_from:]],
        manifest_json(layers=[layer["digest"] + ".tar" for layer in manifest["layers"]]),
        ("config.json", manifest["config"]["size"], open_blob(image, manifest["config"]["digest"]))
    )

    load_res = client.images.load(load.getvalue())

    # Extra safety check: assert that the final image id is equal to the one in the manifest
    assert load_res[0].id == manifest["config"]["digest"], "final image id should match manifest %s == %s" % (load_res[0].id, manifest["config"]["digest"])

    return DockerContainer(manifest["config"]["digest"])




def test_wait_for_hello():
    logging.basicConfig(level=logging.DEBUG)
    print("Starting container")
    with OCIImageContainer("oci_python_image/hello_world/image") as container:
        wait_for_logs(container, "hello py_image_layer!")


test_wait_for_hello()
