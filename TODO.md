# bazel-examples cleanup plan

This repo should stand as a polished reference monorepo showcasing Aspect's
Bazel expertise. Today it carries legacy patterns, stale deps, dead examples,
and ~14 nested `WORKSPACE`s that contradict the "this is a monorepo" message.

This is the tracking plan for burning that down. **Do one thing at a time**, one
PR per item, each independently reviewable and green on CI. Check items off as
they land. Order is roughly by value-to-risk: kill dead weight first, then
modernize, then the harder de-nesting.

Status legend: `[ ]` todo · `[~]` in progress · `[x]` done.

---

## 0. Already done (context)

- [x] `//:gazelle` → `//tools/gazelle:gazelle` via `aspect_gazelle_prebuilt` (#577)
- [x] Orion extensions moved to `.aspect/gazelle/*.axl` (#577)
- [x] Dropped root `//:buildifier` / `//:format` targets; buildifier warnings
      burned to zero in the root module (#577)
- [x] Removed the pre-commit / git-hook auto-format pattern (#577)
- [x] README consolidated into a single file; Aspect CLI documented; docs URLs
      migrated to `aspect.build/docs/*` (#577)

---

## 1. Remove dead / moved / zero-value examples

Quick wins. These don't teach anything current; deleting them sharpens the repo.

- [ ] **`react-cra/`** — `README.md` is just a "MOVED" pointer to
      bazelbuild/examples. create-react-app is deprecated upstream. Delete.
- [ ] **`next.js/`** — "MOVED" pointer only. Delete.
- [ ] **`vue/`** — "MOVED" pointer only. Delete.
- [ ] **`oci_java_image/`** — README-only stub (no BUILD files), last touched
      2023-10, references the long-dead `rules_docker`. Delete (the live OCI
      story is covered by `oci_go_image/` and `oci_python_image/`).
- [ ] **`vercel_pkg/`** — wraps [vercel/pkg](https://github.com/vercel/pkg),
      **archived upstream** since 2022. Demonstrates a dead tool. Delete (nested
      WORKSPACE, so this also removes one of the de-nesting targets in §3).

After each deletion: grep the repo + the docsite for inbound links and fix/remove
them (e.g. `learning/`, `docs/`, sidebar configs in aspect-build/site), and check
CI configs (`.aspect/workflows/`, `.buildkite/`, `.circleci/`, `.github/`,
`.gitlab-ci.yml`) don't target the removed paths.

---

## 2. Update dependency versions

Root deps live in `tools/*.MODULE.bazel` (included by the root `MODULE.bazel`).
Bump in small, themed PRs so a regression bisects cleanly; re-pin lockfiles and
run the affected examples after each. Notable deltas as of this audit
(current → latest on BCR):

**Major bumps (need migration care, own PR each):**
- [ ] `aspect_rules_js` 2.8.3 → 3.x — major; coordinate with `aspect_rules_ts`
      / `aspect_rules_swc`. Touches every JS/TS example.
- [ ] `aspect_rules_py` 1.3.1 → 2.0.0-alpha — major (the template already runs
      2.0.0-alpha). Touches `logger/`, `oci_python_image/`, `py_mypy/`,
      `requirements/`. Consider the uv-based deps flow the template uses.
- [ ] `rules_python` 1.1.0 → 2.0.x — major.
- [ ] `rules_java` 8.6.1 → 9.6.1 and `rules_jvm_external` 6.9 → 7.0 — JVM, major.
- [ ] `buildifier_prebuilt` 6.4.0 → 8.x — major.

**Routine bumps (can batch by theme):**
- [ ] `protobuf` 33.0 → 35.x; verify `grpc-java`, `rules_buf`, `toolchains_protoc`
      still resolve. (Consider dropping `rules_proto` — it's deprecated; the repo
      already loads `proto_library` from `@protobuf//bazel`. See §4.)
- [ ] `gazelle` 0.45.0 → 0.51.x (the bare module, used by Go `go_deps` +
      keep-sorted). Re-verify `aspect_gazelle_prebuilt` stays compatible.
- [ ] `rules_multitool` 1.3.0 → 1.11.x; `aspect_bazel_lib` 2.20.4 → 2.22.x
      (note the `single_version_override`); `aspect_rules_lint` 2.0.0 → 2.7.x
      (watch the sarif_parser linux platform-key issue called out in the template);
      `bazel_env.bzl` 0.2.0 → 0.7.x; `toolchains_llvm` 1.7.0 → 1.8.0;
      `rules_cc` 0.1.1 → 0.2.x; `rules_go` 0.60.0 → 0.61.x; `rules_oci` 2.3.0
      (current); `rules_rust` 0.70.0 (current).
- [ ] Sweep the **nested workspaces** separately — each pins its own deps and
      several are on legacy `WORKSPACE`; fold their bumps into the §3 de-nesting
      work rather than bumping them in place.
- [ ] Add Renovate/dependabot coverage (there's a `renovate.json`) so this
      doesn't rot again — confirm it actually covers the `tools/*.MODULE.bazel`
      split.

---

## 3. Consolidate nested WORKSPACEs into the root monorepo

There are ~14 nested workspaces. A monorepo example repo should *be* a monorepo.
Fold each into the root module unless the nesting is the actual lesson.

**Should stay nested (the isolation IS the point) — document why in each README:**
- [ ] `rules_nodejs_to_rules_js_migration/` — deliberately runs `rules_nodejs`
      and `rules_js` side by side (`@npm` vs `@npm_rules_js`). Keep, but see §4
      (is the migration story still worth shipping in 2026?).
- [ ] `bzlmod/` — its purpose is a self-contained bzlmod-migration demo; nesting
      is intentional. Keep (or retire if redundant once the root is exemplary).

**Easy — minimal/standalone, share root JS deps (do these first):**
- [ ] `jest/` — standard rules_js + SWC jest example.
- [ ] `nestjs/` — standard Node/TS server.
- [ ] `directory_path/` — small `directory_path` tree-artifact demo.
- [ ] `node_snapshot_flags/` — narrow Node snapshot-flags demo.

**Medium — modernize to bzlmod and/or relocate custom extensions to root:**
- [ ] `ts_project_transpiler/` — legacy WORKSPACE → root; folds into the JS deps.
- [ ] `eager-fetch/` — Python lazy-fetch pattern; careful with load ordering so
      consolidation doesn't reintroduce eager fetches (the pattern it teaches).
- [ ] `java-soap/` — bzlmod already; brings JVM/Maven tooling to root.
- [ ] `prisma/` — bzlmod; move its `//bzl` Prisma-engine extension to root `//tools`.
- [ ] `rust_insta_snapshot_test/` — bzlmod; Rust is orthogonal but the root already
      has `rules_rust`. Either consolidate or document the deliberate isolation.

**Hard — legacy WORKSPACE + framework-specific, real work:**
- [ ] `angular-ngc/` — legacy WORKSPACE + Angular ngc macros; large migration.
      Reconcile with the `angular/` example (see §4 redundancy).
- [ ] `check-npm-determinism/` — exercises legacy `rules_nodejs` `npm_install`
      determinism. Decide: port the *check* to rules_js, or retire (it tests a
      dead ruleset's behavior).
- [ ] `go_workspaces/` — legacy `WORKSPACE` Go multi-module + `go.work` + gazelle
      `update-repos`. If the point is "Go workspaces under Bazel," keep nested but
      modernize; otherwise fold the Go example into root (root already has Go).

Per consolidation: delete the nested `WORKSPACE`/`MODULE.bazel`, move deps into
`tools/*.MODULE.bazel`, fix labels, re-run `aspect gazelle`, and confirm
`bazel build //...` + tests from the root see the example.

---

## 4. Old-pattern modernization

- [ ] **Drop `rules_proto`** (deprecated) — `proto_library` now comes from
      `@protobuf//bazel`. The root already loads it from there; remove the
      `rules_proto` `bazel_dep` once no example references `@rules_proto//`.
      (`angular-ngc/` still does — handle with its de-nesting.)
- [ ] **`rules_nodejs_to_rules_js_migration/`** — decide if a *migration from a
      ruleset unmaintained since ~2021* still earns a slot. Either keep as a
      clearly-labelled historical reference or retire.
- [ ] **`angular/` vs `angular-ngc/`** — two Angular examples. Pick the
      canonical one (ngc is the more idiomatic Bazel approach), retire or clearly
      differentiate the other. `angular/` uses third-party `rules_angular`.
- [ ] **`py_mypy/`** — clever aspect-based mypy; confirm it still fits after the
      `rules_py` 2.x / `rules_python` 2.x bumps; relies on community `rules_mypy`.
- [ ] **`speller/`** — last touched 2025-06; audit whether the data-driven-test
      pattern is still current and worth keeping.
- [ ] Sweep for other legacy idioms while in each example: `@npm//` vs
      `:node_modules/...` linking, `ts_project` defaults, `oci_*` patterns vs the
      current `rules_oci` idioms, and any remaining `WORKSPACE`-era macros.

---

## 5. Polish (after the above)

- [ ] Add a short `README.md` to the example dirs that lack one
      (`protobuf/`, `npm_packages/`, `nodejs_apps/`, `check-npm-determinism/`, …)
      stating what each demonstrates — a reference repo should be self-describing.
- [ ] Re-verify every CI provider config (`.aspect/workflows/`, `.buildkite/`,
      `.circleci/`, `.github/`, `.gitlab-ci.yml`) still builds/tests the post-cleanup
      target set, and that GitHub + GitLab mirrors stay in sync.
- [ ] Keep the docsite (aspect-build/site, esp. the Bazel 200-series courses that
      use this repo) updated in lockstep with each structural change.
