# Qwik monorepo example
In this folder you will find a monorepo example of a Qwik app and a Qwik library.

The app uses the library as an internal dependency. Using Bazel we can build and test both of them in parallel.

## About Bazel

See the [root README](/README.bazel.md) for general information about using Bazel in this monorepo.

## Developer Workflows

### Run Tests

Do one of these:

```shell
# Test the app using typical JS commands
cd qwik/app; npm test
# Test the lib using typical JS commands
cd qwik/lib; npm test
# Use the Bazel CLI directly, testing all apps and libs
bazel test //qwik/...
```


### Start the App

**With hot-reload**:

```shell
cd qwik/app; npm run dev
```

**With vite restarting (>5s for update)**:

```shell
./tools/ibazel run //qwik/app:start
```