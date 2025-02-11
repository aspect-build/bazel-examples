# Node.js built-in test runner

Overview:
https://nodejs.org/en/learn/test-runner/introduction


## Collecting coverage

Flags needed to enable coverage:
https://nodejs.org/api/test.html#collecting-code-coverage

```
% bazel coverage node_test_coverage:all --nocache_test_results --combined_report=lcov

INFO: Using default value for --instrumentation_filter: "^//node_test_coverage[/:]".
INFO: Override the above default with --instrumentation_filter
INFO: Analyzed target //node_test_coverage:test (0 packages loaded, 3 targets configured).
INFO: LCOV coverage report is located at /private/var/tmp/_bazel_alexeagle/2442372bc9d5c407aa13d3b43880afe0/execroot/_main/bazel-out/_coverage/_coverage_report.dat
 and execpath is bazel-out/_coverage/_coverage_report.dat
INFO: From Coverage report generation:
Feb 11, 2025 11:51:53 AM com.google.devtools.coverageoutputgenerator.Main getTracefiles
INFO: Found 1 tracefiles.
Feb 11, 2025 11:51:53 AM com.google.devtools.coverageoutputgenerator.Main parseFilesSequentially
INFO: Parsing file bazel-out/darwin_arm64-fastbuild/testlogs/node_test_coverage/test/coverage.dat
Feb 11, 2025 11:51:53 AM com.google.devtools.coverageoutputgenerator.Main getGcovInfoFiles
INFO: No gcov info file found.
Feb 11, 2025 11:51:53 AM com.google.devtools.coverageoutputgenerator.Main getGcovJsonInfoFiles
INFO: No gcov json file found.
Feb 11, 2025 11:51:53 AM com.google.devtools.coverageoutputgenerator.Main getProfdataFileOrNull
INFO: No .profdata file found.
Feb 11, 2025 11:51:53 AM com.google.devtools.coverageoutputgenerator.Main runWithArgs
WARNING: There was no coverage found.
```