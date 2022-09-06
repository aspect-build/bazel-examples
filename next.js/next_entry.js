const { spawnSync } = require('child_process');
// This path is currently a hack an specific to this projects layout with
// ../../../../../ being the path from the the next_bin binary runfiles root
// to the execroot.
// TODO: Generalize this path in the future.
const entry = require.resolve(
  `../../../../../${process.env.BAZEL_BINDIR}/node_modules/next/dist/bin/next`
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
