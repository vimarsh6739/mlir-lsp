# Enzyme-JAX MLIR language server

This standalone Bazel workspace builds the dialect-aware MLIR language server
from Enzyme-JAX without sharing the Enzyme-JAX checkout's Bazel output base.

`workspace.bzl` selects the source checkout. While developing locally, leave
`OVERRIDE_ENZYMEXLA_PATH` set and refresh the copied external repository after
source changes:

```sh
bazel sync --only=enzyme_ad
./install.sh
```

The installer writes `enzymexla-lsp-server` to `~/.local/bin`. Restart any
attached Neovim MLIR LSP clients after installing a new build.

For a reproducible archive build, set `ENZYMEXLA_COMMIT` and
`ENZYMEXLA_SHA256` to a published revision containing the server, clear
`OVERRIDE_ENZYMEXLA_PATH`, and build from a clean repository cache.
