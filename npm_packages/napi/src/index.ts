/// <reference types="node" />
import { resolve } from 'node:path';

// TODO: codegen from lib.rs to avoid manually keeping them in sync
// maybe https://crates.io/crates/tslink
declare interface RustNative {
  hello: (name: string) => string;
}

// TODO: codegen from adder.h to avoid manually keeping them in sync
declare interface CNative {
  add: (first: number, second: number) => number;
}

// Resolve the native.node file relative to this library's location
export const rust: RustNative = require(resolve(
  __dirname,
  'my_native_rust.node'
));
export const c: CNative = require(resolve(__dirname, 'my_native_c.node'));
