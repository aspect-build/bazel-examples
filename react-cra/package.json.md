# eslintConfig failure

The following eslint config was removed from package.json,

```
"eslintConfig": {
  "extends": [
    "react-app",
    "react-app/jest"
  ]
},
```

due to the failure,

```
ERROR: /Users/greg/aspect/rules/bazel-examples/react/create-react-app/BUILD.bazel:39:18: ReactScripts build failed: (Exit 1): build__js_binary.sh failed: error executing command bazel-out/darwin-opt-exec-2B5CBBC6/bin/build__js_binary.sh build

Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
Creating an optimized production build...
Failed to compile.

[eslint] Failed to load config "react-app" to extend from.
Referenced from: /private/var/tmp/_bazel_greg/7a034e9fc29c53564111b46ffd39815e/sandbox/darwin-sandbox/5395/execroot/__main__/bazel-out/darwin-fastbuild/bin/package.json
```
