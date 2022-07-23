load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load(":defs.bzl", "my_nodejs")

# Trivial test fixture: a nodejs program that writes to a file
write_file(
    name = "js",
    out = "some.js",
    content = ["require('fs').writeFileSync(process.argv[2], 'stuff')"],
)

write_file(
    name = "write_expected",
    out = "expected",
    content = ["stuff"],
)

# Here, my_nodejs is a fake for something like nodejs_binary or
# some other custom rule that runs node.
my_nodejs(
    name = "run",
    out = "thing",
    entry_point = "some.js",
)

# Assert that the node program wrote the file we expect
diff_test(
    name = "test_custom_rule",
    file1 = "expected",
    file2 = "thing",
)
