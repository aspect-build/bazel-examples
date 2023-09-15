"""Library functions copied from various prisma packages."""

load(":constants.bzl", "QUERY_ENGINE_LIBRARY")

def _get_node_api_name(platform, is_url):
    """Copied from.

    https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/get-platform/src/getNodeAPIName.ts
    """

    nix_base = "libquery_engine"

    if "windows" in platform:
        return "query_engine.dll.node" if is_url else "query_engine-{}.dll.node".format(platform)

    if "darwin" in platform:
        return nix_base + ".dylib.node" if is_url else "{}-{}.dylib.node".format(nix_base, platform)

    return nix_base + ".so.node" if is_url else "{}-{}.so.node".format(nix_base, platform)

def get_download_url(version, platform, binary_type):
    """Get the URL to download a prisma engine binary.

    Copied from
    https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/fetch-engine/src/utils.ts#L53-L77

    Hardcoded:
      channel = "all_commits" (usage site):
        https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/fetch-engine/src/download.ts#L156
      extension = ".gz"
      baseURL = "https://binaries.prisma.sh"

    Args:
      version: version to get the url for (git commit sha).
      platform: platform to get the url for
      binary_type: which engine binary to get the url for

    Returns:
      URL to downalod the binary as a string.
    """
    base_url = "https://binaries.prisma.sh"

    if platform == "windows" and binary_type != QUERY_ENGINE_LIBRARY:
        extension = ".exe.gz"
    else:
        extension = ".gz"

    if binary_type == QUERY_ENGINE_LIBRARY:
        binary_name = _get_node_api_name(platform, is_url = True)
    else:
        binary_name = binary_type

    return "{}/all_commits/{}/{}/{}{}".format(base_url, version, platform, binary_name, extension)

def get_binary_name(binary_type, platform):
    """Get the full name for an engine binary on the local filesystem.

    Copied from:
    https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/fetch-engine/src/download.ts#L350-L356

    Args:
      binary_type: which engine binary to get the name for
      platform: which platform to get the binary name for

    Returns:
      Name of the binary as a string.
    """

    if binary_type == QUERY_ENGINE_LIBRARY:
        return _get_node_api_name(platform, is_url = False)

    extension = ".exe" if platform == "windows" else ""
    return "{}-{}{}".format(binary_type, platform, extension)

def parse_distro(os_release_input):
    """Get the distro from /etc/os-release.

    Original:
    https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/get-platform/src/getPlatform.ts#L103-L216

    Args:
      os_release_input: content of /etc/os-release to parse.

    Returns:
      distro as string (or fails).
    """

    map = {
        "alpine": "musl",
        "debian": "debian",
        "ubuntu": "debian",
    }

    id = ""
    id_like = ""
    id_like_result = ""
    for line in os_release_input.splitlines():
        # Try getting the distro name with the property ID
        # Debian doesn't have the ID_LIKE
        if line.startswith("ID="):
            id = line.removeprefix("ID=")
            result = map.get(id)
            if result:
                return result

        # if with the property ID was not succefull we try with ID_LIKE
        if line.startswith("ID_LIKE="):
            id_like = line.removeprefix("ID_LIKE=")
            for split_id in id_like.split(" "):
                result = map.get(split_id.strip("\""))
                if result and id_like_result == "":
                    id_like_result = result

    if id_like_result != "":
        return id_like_result

    if id == "" and id_like == "":
        fail("couldn't find ID= or ID_LIKE= line in /etc/os-release")

    fail("unknown linux distribution 'ID={}; ID_LIKE={}'".format(id, id_like))

_debian_arch_from_bazel_arch = {
    "amd64": "x86_64",
}

def compute_lib_ssl_specific_paths(distro, bazel_arch):
    """Get paths for SSL lib.

    Original:
    https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/get-platform/src/getPlatform.ts#L290-L312

    Args:
      distro: Distro as returned from parse_distro.
      bazel_arch: CPU architecture as returned from ctx.os.arch

    Returns:
      List of paths to look in (or fails).
    """

    if distro == "musl":
        return ["/lib"]

    if distro == "debian":
        debian_arch = _debian_arch_from_bazel_arch[bazel_arch]

        return [
            "/usr/lib/{}-linux-gnu".format(debian_arch),
            "/lib/{}-linux-gnu".format(debian_arch),
        ]

    fail("unknown distro {}".format(distro))

def get_ssl_version(ctx, paths):
    """Get the SSL version of the host.

    Original:
    https://github.com/prisma/prisma/blob/71fed12cedb23721c32e44c648ff86b6393582fa/packages/get-platform/src/getPlatform.ts#L334-L394

    Args:
      ctx: repository rule context
      paths: paths to look for libssl in.

    Returns:
      The libssl version (or fails)
    """

    for path in paths:
        res = ctx.execute(["ls", path])
        if res.return_code != 0:
            fail("failed to ls '{}': {}".format(path, res.stderr))

        for line in res.stdout.splitlines():
            if line.startswith("libssl.so."):
                return line.removeprefix("libssl.so.")

    fail("couldn't find libssl in {}".format(paths))
