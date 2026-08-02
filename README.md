# mlir-lsp

A dialect-rich distribution of MLIR's language server for real-world compiler
workspaces. It delegates the protocol implementation to upstream MLIR and owns
the dialect registry, dependency pins, source build, and editor integration.

The server currently matches Enzyme-JAX's registry and adds the StableHLO Check
and Interpreter dialects. This covers the upstream MLIR, Enzyme, EnzymeXLA,
StableHLO/MHLO, Shardy, Triton, CUDA Tile, communication, and distributed IR
used by Enzyme-JAX.

## Features

- Live parser and verifier diagnostics.
- Completion for operations, attributes, types, blocks, and SSA values.
- Hover information and generic operation forms.
- Definitions and references for SSA values, blocks, and symbols.
- Document symbols and symbol-table navigation.

These are upstream MLIR LSP semantics. Operation names do not navigate to their
TableGen or C++ implementations.

## Build and install

The source build requires `bazel` on `PATH`, a C++ toolchain, and approximately
the same resources as an LLVM/MLIR build. The repository pins Bazel 7.7.0.

```sh
git clone https://github.com/vimarsh6739/mlir-lsp.git
cd mlir-lsp
./install.sh
```

The installer builds an optimized binary and writes it to
`~/.local/bin/mlir-lsp-server`. Override the destination when needed:

```sh
INSTALL_PREFIX="$HOME/bin" ./install.sh
```

To build without installing:

```sh
bazel build //:mlir-lsp-server
./bazel-bin/mlir-lsp-server --help
```

Build outputs are retained for fast incremental updates.

### Local Enzyme-JAX development

Set `OVERRIDE_ENZYME_JAX_PATH` in `workspace.bzl` to a local Enzyme-JAX
checkout, then refresh its copied repository after source changes:

```sh
bazel sync --only=enzyme_ad
./install.sh
```

Clear the override to return to the pinned archive.

## Neovim with Lazy.nvim

The repository is both the source distribution and a small Neovim plugin. This
Lazy.nvim specification builds the server and configures Neovim's native LSP
client for `mlir` buffers:

```lua
{
  'vimarsh6739/mlir-lsp',
  lazy = false,
  build = './install.sh',
  config = function()
    require('mlir_lsp').setup()
  end,
}
```

The default command is `~/.local/bin/mlir-lsp-server`. It can be overridden:

```lua
require('mlir_lsp').setup {
  lsp = {
    cmd = { '/custom/path/mlir-lsp-server' },
  },
}
```

This uses `vim.lsp.config` and `vim.lsp.enable`, the current Neovim 0.11+
configuration API.

## Visual Studio Code

Install LLVM's MLIR extension and set the server path:

```json
{
  "mlir.server_path": "/home/you/.local/bin/mlir-lsp-server"
}
```

The authoritative registry is [mlir-lsp.cpp](mlir-lsp.cpp). Keeping the list in
the executable makes supported dialects explicit and reviewable.

## License

Apache License v2.0 with LLVM Exceptions.
