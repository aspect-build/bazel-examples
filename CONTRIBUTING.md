# How to Contribute

## Formatting

- Starlark files should be formatted by buildifier.
- JS/TS/Html/Css/Json files should be formatted by prettier.

We suggest using a pre-commit hook to automate this.
First [install pre-commit](https://pre-commit.com/#installation),
then run

```shell
pre-commit install
```

Otherwise later tooling on CI may yell at you about formatting/linting violations.
