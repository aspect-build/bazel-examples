#!/usr/bin/env node
// A simple wrapper around the napi-rs typegen CLI to expose the type definition generation without also running rustc.
// WORKAROUND https://github.com/napi-rs/napi-rs/issues/3049
const typeDefDir = process.argv[2]
const typingsOut = process.argv[3]
require("@napi-rs/cli").generateTypeDef({ typeDefDir }).then(({ dts, exports }) => {
  if (!exports.length) {
    console.error('No exports found in the type definition files')
    process.exit(1)
  }
  require('node:fs').writeFileSync(typingsOut, dts, 'utf-8')
}).catch((error) => {
  console.error('Error:', error)
  process.exit(1)
});