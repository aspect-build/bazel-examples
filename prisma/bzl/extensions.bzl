load("//bzl:local_config_platform.bzl", _local_config_platform_repo = "local_config_platform")
load("//bzl:repositories.bzl", _prisma_setup = "prisma_setup")

def _prisma_local_config_platform_impl(ctx):
    _local_config_platform_repo(name = "prisma_local_config_platform")

prisma_local_config_platform = module_extension(
    implementation = _prisma_local_config_platform_impl,
)

def _prisma_engines_impl(ctx):
    _prisma_setup()

prisma_engines = module_extension(
    implementation = _prisma_engines_impl,
)
