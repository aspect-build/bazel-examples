const path = require('path')

console.log(process.cwd())
globalThis.path = process.cwd()
globalThis.file = __dirname
const name = 'I am geezy'

console.log(process.argv)
globalThis.firstArg = process.argv[2]
globalThis.secondArg = process.argv[3]
