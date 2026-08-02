# Personal MLIR language server

This standalone Bazel workspace owns a personal, dialect-aware MLIR language
server. It uses MLIR's upstream LSP implementation and composes the dialect
registries needed across projects without sharing their Bazel output bases.

The authoritative registry is in `mlir-lsp.cpp`. It currently matches the
Enzyme-JAX language server: Enzyme-JAX's registry plus the StableHLO Check and
Interpreter dialects.

`workspace.bzl` selects the source checkout. While developing locally, leave
`OVERRIDE_ENZYMEXLA_PATH` set and refresh the copied external repository after
source changes:

```sh
bazel sync --only=enzyme_ad
./install.sh
```

The installer writes `mlir-lsp-server` to `~/.local/bin`. Restart any
attached Neovim MLIR LSP clients after installing a new build.

For a reproducible archive build, set `ENZYMEXLA_COMMIT` and
`ENZYMEXLA_SHA256` to a published revision exposing the registry, clear
`OVERRIDE_ENZYMEXLA_PATH`, and build from a clean repository cache.

## Dialect roadmap

- [x] Register Enzyme-JAX, StableHLO Check, and StableHLO Interpreter.
- [ ] Register every upstream MLIR dialect and extension.
- [ ] Add independently versioned MLIR ecosystems as demand arises:
  [IREE](https://github.com/iree-org/iree),
  [torch-mlir](https://github.com/llvm/torch-mlir),
  [ONNX-MLIR](https://github.com/onnx/onnx-mlir),
  [CIRCT](https://github.com/llvm/circt), and project-specific research
  dialects.
- [ ] Support private dialect bundles without requiring them to be published or
  sent to a remote service.
- [ ] Give each external project a pinned archive, local checkout override, Bazel
  overlay, and narrowly scoped compatibility patches when needed.
- [ ] Add one parsing, completion, hover, definition, reference, and diagnostics
  smoke test for each dialect bundle.
- [ ] Evaluate loadable dialect plugins if static linking becomes too expensive.
- [ ] Extract this workspace into a standalone open-source project once the
  registry and dependency interfaces have stabilized.
