// This is a custom next js_binary entry_point.
// See comment in bazel/next.bzl for more information as to why this is needed.

const path = require('path');
const { spawnSync } = require('child_process');
const entry = require.resolve(
  path.join(
    process.env.JS_BINARY__EXECROOT,
    process.env.BAZEL_BINDIR,
    process.env.BAZEL_PACKAGE,
    process.env.NEXT_BIN
  )
);
const args = process.argv.slice(2);
const spawnOptions = {
  shell: process.env.SHELL,
  stdio: [process.stdin, 'ignore', process.stderr],
};
const res = spawnSync(entry, args, spawnOptions);
if (res.status === null) {
  // Process can fail with a null exit-code (e.g. OOM), handle appropriately
  throw new Error(`Process terminated unexpectedly: ${res.signal}`);
}
process.exit(res.status);
