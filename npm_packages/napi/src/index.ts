/// <reference types="node" />
import { resolve } from 'node:path';
import RustNative from './hello_binding';

// TODO: codegen from adder.h to avoid manually keeping them in sync
declare interface CNative {
  add: (first: number, second: number) => number;
}

// Resolve the native.node file relative to this library's location
export const rust: RustNative = require(resolve(
  __dirname,
  'hello_binding.node'
));
export const c: CNative = require(resolve(__dirname, 'my_native_c.node'));
