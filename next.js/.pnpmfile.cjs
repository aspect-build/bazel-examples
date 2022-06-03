function readPackage(pkg, context) {
    if (pkg.name === 'esbuild') {
        pkg.peerDependencies = {
            ...pkg.peerDependencies,
            'kind-of': '*',
            'strip-bom-string': '*',
            'object-assign': '*',
            'regenerator-runtime': '*',
        }
        context.log(
            `Adding JS runtimes as peerDependency to ${pkg.name}@${pkg.version}`
        )
    }

    return pkg
}

module.exports = {
    hooks: {
        readPackage,
    },
}
