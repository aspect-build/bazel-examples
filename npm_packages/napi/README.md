# Node-API for Node.js

This package demonstrates interop between languages, using https://nodejs.org/api/n-api.html

As described on https://nodejs.org/api/addons.html,

> Addons are dynamically-linked shared objects written in C++. The require() function can load addons as ordinary Node.js modules. Addons provide an interface between JavaScript and C/C++ libraries.

Since Bazel can easily produce such shared objects, there's no need for a purpose-built build system layer like https://napi.rs or https://github.com/cmake-js/cmake-js (both of which seem hacky compared with Bazel).

## Setup

We'll need standard rules_rust and rules_cc to get the compilation rules, and use rules_js to execute the result.

One important bit of setup: we need the header files to develop against the Node.js toolchain, so set [`include_headers`](https://github.com/bazel-contrib/rules_nodejs/blob/main/docs/Core.md#nodejs_repositories-include_headers) in the `MODULE.bazel` file:

```
node.toolchain(
    include_headers = True,
    node_version = "20.18.0",
)
```

## From Rust

We simply use the documented API at https://docs.rs/napi/latest/napi/. See the code listings in the `src/` folder beneath this README.

As a simple example here's `src/lib.rs` containing:

```rust
use napi_derive::napi;

#[napi]
pub fn hello(name: String) -> String {
  format!("Hello from Rust code, {}!", name)
}
```

To call this code from Node.js, we need a shared object, produced by the [rust_shared_library](https://bazelbuild.github.io/rules_rust/rust.html#rust_shared_library) rule. It needs to depend on `@rules_nodejs//nodejs/headers:current_node_cc_headers` so the linker can find the symbols referenced by the napi crate.

Since the output of `rust_shared_library` has a `.dylib` extension on MacOS or a `.so` extension on Linux, we need a stable name.
Node.js standard is for bindings to be named with a `.node` extension, so we use a `copy_file` rule.

Finally we need to wrap the `.node` file with a Node.js interface. We ought to be able to generate this, perhaps using https://crates.io/crates/tslink. In the meantime it's easy enough to write it, but we have to keep the interface up-to-date:

```typescript
declare interface Lib {
    hello: (name: string) => string;
}

export const lib: Lib = require(require('path').resolve(__dirname, 'lib.node'));
```

Now we can write any Node.js code we like and call this wrapper without needing to know it has Rust code behind the scenes.

## From C

Node.js ships with the [`node_api.h`](https://github.com/nodejs/node-api-headers/blob/main/include/node_api.h) header file,
so just follow the instructions at https://nodejs.org/api/n-api.html#usage to produce a binding file. See the code listings in the `src/` folder beneath this README.

```c
#define NAPI_VERSION 3
#include <node_api.h>
#include "adder.h"

static napi_value Add(napi_env env, napi_callback_info info) {
    ...
    return return_val;
}

static napi_value Init(napi_env env, napi_value exports) {
    napi_value fn;
    napi_status status = napi_create_function(env, NULL, 0, Add, NULL, &fn);
    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Unable to wrap native function");
        return NULL;
    }
    
    status = napi_set_named_property(env, exports, "add", fn);
    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Unable to populate exports");
        return NULL;
    }
    
    return exports;
}

NAPI_MODULE_INIT() {
    return Init(env, exports);
}
```

Then we use the [`linkshared`](https://bazel.build/reference/be/c-cpp#cc_binary.linkshared) attribute of `cc_binary` to
request a shared object output, and similar to above we use a `copy_file` rule to rename the result to the `.node` extension.

The TypeScript wrapper looks the same as for Rust, since we are just pointing to any shared object file.

## Putting it together

Now we just have a Node.js app in `nodejs_apps/typescript` which has a type-checked usage of the native libraries above,
by importing the wrapper and calling the functions:

```typescript
import { rust, c } from '@bazel-examples/napi';

console.log(rust.hello('NodeJS'));
console.log('C code does math: 1 + 2 = ' + c.add(1, 2));
```

and we can verify by running it:

```sh
alexeagle@aspect-build bazel-examples % bazel run nodejs_apps/typescript:main
INFO: Build completed successfully, 3 total actions
INFO: Running command line: bazel-bin/nodejs_apps/typescript/main_/main

Hello from Rust code, NodeJS!
C code does math: 1 + 2 = 3
```
