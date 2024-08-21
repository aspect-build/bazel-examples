# Vendored third-party dependencies

Occasionally an organization decides to compile directly from source some or all
of their dependencies. Most famously Google does this, but other organizations
with strict auditing and provenance requirements sometimes do so also. A common
layout is a third-party directory with a sub-directory per dependency.

The word "vendored" probably comes from the Ruby ecosystem, where the popular
dependency management tooling copies dependencies into a directory called
vendor.
