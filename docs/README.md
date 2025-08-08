# r3oTop / Rebol 3 Oldes — API Documentation

## Overview
This repository contains reusable utilities, CLI tools, and examples for Rebol 3 (Oldes branch). This documentation covers public APIs, functions, and components, with examples and usage instructions.

- Interpreter: Rebol 3 (Oldes)
- How to load modules: `do %path/to/file.r3`

## Quickstart
- Install Rebol 3 (Oldes)
- Clone this repository
- From the repo root, load the modules you need. For example:
  ```rebol
  do %output/eprt-to-write-to-stderr.r3
  do %output/text-output-stylizer-via-ANSI-control-codes.r3
  do %functions/tracer/bomb-burst-unwind-and-dprt.r3
  do %functions/reusable/writers/sling.r3
  do %loops/sfor-safe-for-contruct.-and-test-harness.r3
  do %loops/blocks/retrieve-block-item-via-index.r3
  do %functions/reusable/tools/find-missing-bracket-approx.r3  ;; CLI tool
  ```

## Contents
- Output utilities: `docs/output.md`
  - `eprt`, `bprt`, `stylize`, `hue-datatype`
- Tracing and error utilities: `docs/tracer.md`
  - `dprt`, `ErrMsg`, `SuccessMsg`, `WarnMsg`, verbosity toggles, error object helpers
- Data writers and accessors: `docs/writers-sling.md`
  - `grab`, `grab-item`, `sling`
- Looping and block helpers: `docs/loops.md`
  - `sfor` (safe-for), `retrieve-block-item-via-index`
- CLI tools: `docs/tools.md`
  - `find-missing-bracket-approx.r3`
- Recycling helper (Windows): `docs/recycle.md`
  - `recycle-item`

## Conventions
- Function refinements use `/refinement` style, e.g., `sling/path/create ...`
- Many scripts include built-in demonstrations/tests. When embedding in your project, you may remove or guard those demo calls.
- All code examples use Rebol syntax blocks.

## Support
See `README.md` in the project root for broader context. File issues or PRs to improve docs and coverage.