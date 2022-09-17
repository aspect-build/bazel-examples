# Canonical of BUILD file generation for JavaScript and TypeScript

Example monorepo example that is structured for JavaScript and TypeScript BUILD
file generation using the Aspect CLI.

Library, feature and app names were generated with https://www.fantasynamegenerators.com/software-names.php

## Structure

Sources in this monorepo example is structured into three top-level folders:

- apps: Applications
- libs: Shared libraries that are not linked but imported via relative paths `../../libs/foo`
- packages: Shared code that is consumed via named links and imported from node_modules `@example/foo`

Using bazel query to list all of the targets in the repository is a quick way to see they monorepo structure:

```
bazel query ... | grep -v node_modules | grep -v _validate
//:tsconfig
//apps/triad:triad
//apps/triad:triad_lib
//apps/triad/pivot:pivot
//apps/triad/vibe:vibe
//libs/rune/asap:asap
//libs/rune/rebus:rebus
//packages/iris:iris
//packages/iris:iris_lib
//packages/iris/abra:abra
//packages/iris/pitch:pitch
```

(we filter out "node_modules" and typescript boilerplate targets "_validate" targets)
