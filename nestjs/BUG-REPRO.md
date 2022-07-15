# Bug Repro

Slack thread: https://bazelbuild.slack.com/archives/CEZUUKQ6P/p1657798365754249

Building with: `bazel build //:repro-bug` throws an error of:
```
ERROR: /Users/jesse/Development/bazel-examples/nestjs/BUILD:18:12: Copying files to directory failed: (Exit 1): bash failed: error executing command /bin/bash -c bazel-out/darwin_arm64-fastbuild/bin/repro-bug.run_shell_0.sh
stdout (/private/var/tmp/_bazel_jesse/3bb71b40a7a6f784d6beace2776d5d07/execroot/__main__/bazel-out/_tmp/actions/stdout-2) exceeds maximum size of --experimental_ui_max_stdouterr_bytes=1048576 bytes; skipping
Target //:repro-bug failed to build
Use --verbose_failures to see the command lines of failed build steps.
```

At this point if you check the regular node modules for `@nestjs/common` it is a symlink as expected:
```
jesse@jessesaspectair nestjs % ls -la bazel-bin/node_modules/@nestjs/common
lrwxr-xr-x  1 jesse  wheel  223 15 Jul 11:48 bazel-bin/node_modules/@nestjs/common -> /private/var/tmp/_bazel_jesse/3bb71b40a7a6f784d6beace2776d5d07/execroot/__main__/bazel-out/darwin_arm64-fastbuild/bin/node_modules/.aspect_rules_js/@nestjs+common@8.4.7_47vcjb2de6lyibr6g4enoa5lyu/node_modules/@nestjs/common
```

However if you check for node modules under `repro-bug` they are there (should they be?) and they are actual files, not symlinks:
```
jesse@jessesaspectair nestjs % ls -la bazel-bin/repro-bug/node_modules/@nestjs/common
total 88
drwxr-xr-x  21 jesse  wheel    672 15 Jul 11:59 .
drwxr-xr-x   3 jesse  wheel     96 15 Jul 11:59 ..
-r-xr-xr-x   1 jesse  wheel   1112 15 Jul 11:59 LICENSE
-r-xr-xr-x   1 jesse  wheel     93 15 Jul 11:59 PACKAGE.md
-r-xr-xr-x   1 jesse  wheel  16147 15 Jul 11:59 Readme.md
dr-xr-xr-x  15 jesse  wheel    480 15 Jul 11:59 cache
-r-xr-xr-x   1 jesse  wheel   1866 15 Jul 11:59 constants.d.ts
-r-xr-xr-x   1 jesse  wheel   2466 15 Jul 11:59 constants.js
dr-xr-xr-x   7 jesse  wheel    224 15 Jul 11:59 decorators
dr-xr-xr-x  14 jesse  wheel    448 15 Jul 11:59 enums
dr-xr-xr-x  48 jesse  wheel   1536 15 Jul 11:59 exceptions
dr-xr-xr-x   8 jesse  wheel    256 15 Jul 11:59 file-stream
dr-xr-xr-x  11 jesse  wheel    352 15 Jul 11:59 http
-r-xr-xr-x   1 jesse  wheel   1130 15 Jul 11:59 index.d.ts
-r-xr-xr-x   1 jesse  wheel   1116 15 Jul 11:59 index.js
dr-xr-xr-x  36 jesse  wheel   1152 15 Jul 11:59 interfaces
-r-xr-xr-x   1 jesse  wheel    932 15 Jul 11:59 package.json
dr-xr-xr-x  20 jesse  wheel    640 15 Jul 11:59 pipes
dr-xr-xr-x   9 jesse  wheel    288 15 Jul 11:59 serializer
dr-xr-xr-x   9 jesse  wheel    288 15 Jul 11:59 services
dr-xr-xr-x  28 jesse  wheel    896 15 Jul 11:59 utils
```

Attempting to get more logs with: `bazel build //:repro-bug --experimental_ui_max_stdouterr_bytes=10485760` results it more logs than can be pasted here with no immediately noticable error
