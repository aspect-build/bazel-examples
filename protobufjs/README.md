# Example of protobuf.js + @grpc/grpc-js + rules_ts + rules_js 

A simple example for `protobuf.js` + `@grpc/grpc-js` implementing a dummy weather forecast service.


### Running the example

You need to start the server first by running;

```bash
bazel run //src:server

# output will look like this

INFO: Analyzed target //src:server (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //src:server up-to-date:
  bazel-bin/src/server.sh
INFO: Elapsed time: 0.266s, Critical Path: 0.01s
INFO: 1 process: 1 internal.
INFO: Build completed successfully, 1 total action
INFO: Build completed successfully, 1 total action
Server is listening on 0.0.0.0:1334
Get forecast for city: 1 / country: 0
```

then run the client;

```bash
bazel run //src:client

# output will look like this

INFO: Analyzed target //src:client (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //src:client up-to-date:
  bazel-bin/src/client.sh
INFO: Elapsed time: 0.215s, Critical Path: 0.01s
INFO: 1 process: 1 internal.
INFO: Build completed successfully, 1 total action
INFO: Build completed successfully, 1 total action
Forecast
Temperature 27°C LOW / 32°C HIGH
Wind direction is North at 10 km/h
```

