# Qwik monorepo example
In this folder you will find a monorepo example of a Qwik app and a Qwik library.

The app uses the library as an internal dependency. Using Bazel we can build and test both of them in parallel.

And using IBazel we can have a hot reload of the app when the library changes.

## Commands:

### Build the example:
```
bazel build //qwik/...
```

### Test the example:
```
bazel test //qwik/...
```


### Start the hot reload app server:
```
ibazel run //qwik/app:devserver
```
* On Linux the hot reload works just once (see alternative below)
* On MacOS the hot reload works as expected

### For Linux you can use a slower approach like so (>5s for update):
```
ibazel run //qwik/app:start
```