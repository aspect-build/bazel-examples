# Eager dependency fetching

Shows how we might accidentally fetch external repositories not needed for the user-requested targets to be built, and how to write a test preventing that from happening.

Accompanies a blog post: <https://blog.aspect.dev/avoid-eager-fetches>

Check out this example and run to see the failure:

```
% ./test_no_eager_fetch.sh
Starting local Bazel server and connecting to it...
...
FAIL: pip_deps was fetched
```

To make the test pass, see the commented lines in WORKSPACE where we can switch the `load` statement.
