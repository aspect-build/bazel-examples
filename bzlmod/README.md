# bzlmod_demo
Show Aspect's rules working with Bazel 5 bzlmod (empty WORKSPACE file)

Read the blog post: <https://blog.aspect.dev/bzlmod>

Tour:
- WORKSPACE file is empty
- MODULE.bazel contains just one `bazel_dep` line to bring in each dependency, compared with dozens of lines needed in WORKSPACE
- The swc/ folder proves that we can use that rule to transpile TS files
- The nodejs/ folder proves that we can use a nodejs toolchain to run node programs
