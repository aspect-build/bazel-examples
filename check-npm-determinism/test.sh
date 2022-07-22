#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Check NPM determinism

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$script_dir"

rm -rf tmp
mkdir tmp

echo "Fetching first @npm"
fetch_1_output_base=tmp/fetch_1
bazel --output_base="$fetch_1_output_base" fetch @npm//...
node_modules_1="$fetch_1_output_base/external/npm/_/node_modules"

echo "Fetching second @npm"
fetch_2_output_base=tmp/fetch_2
bazel --output_base="$fetch_2_output_base" fetch @npm//...
node_modules_2="$fetch_2_output_base/external/npm/_/node_modules"

echo "Diffing @npm repositories' node_modules"
if diff -qr "$node_modules_1" "$node_modules_2"; then
  echo "All files match!"
fi
