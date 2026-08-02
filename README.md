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
- Tree-sitter highlighting through
  [felixtensor/tree-sitter-mlir](https://github.com/felixtensor/tree-sitter-mlir).

These are upstream MLIR LSP semantics. Operation names do not navigate to their
TableGen or C++ implementations.

## Build and install

The source build requires Bazel or Bazelisk, a C++ toolchain, and approximately
the same resources as an LLVM/MLIR build. The repository pins Bazel 7.7.0 and
uses Enzyme's public read-only Bazel cache.

```sh
git clone https://github.com/vimarsh6739/mlir-lsp.git
cd mlir-lsp
./install.sh
```

The installer builds an optimized binary and writes it to
`~/.local/bin/mlir-lsp-server`. Override either tool or destination when needed:

```sh
BAZEL=bazelisk INSTALL_DIR="$HOME/bin" ./install.sh
```

To build without installing:

```sh
bazel build --config=public_cache //:mlir-lsp-server
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
Lazy.nvim specification builds the server, configures Neovim's native LSP
client, installs the pinned MLIR Tree-sitter parser and its queries, and enables
highlighting for `mlir` buffers:

```lua
{
  'vimarsh6739/mlir-lsp',
  lazy = false,
  build = './install.sh',
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      lazy = false,
      build = ':TSUpdate',
    },
  },
  config = function()
    require('mlir_lsp').setup()
  end,
}
```

The Tree-sitter integration follows `nvim-treesitter`'s `main` API. It
currently requires Neovim 0.12 and `tree-sitter-cli` 0.26.1. For an LSP-only
setup on Neovim 0.11, omit the dependency and call
`setup { treesitter = false }`.

The default command is `~/.local/bin/mlir-lsp-server`. It can be overridden:

```lua
require('mlir_lsp').setup {
  lsp = {
    cmd = { '/custom/path/mlir-lsp-server' },
  },
}
```

This uses `vim.lsp.config` and `vim.lsp.enable`, the current Neovim 0.11+
configuration API. Mason integration is deferred until prebuilt releases are
available through a Mason registry.

## Visual Studio Code

Install LLVM's MLIR extension and set the server path:

```json
{
  "mlir.server_path": "/home/you/.local/bin/mlir-lsp-server"
}
```

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
- [ ] Give each external project a pinned archive, local checkout override,
  Bazel overlay, and narrowly scoped compatibility patches when needed.
- [ ] Add parsing, completion, hover, definition, reference, and diagnostics
  smoke tests for every dialect bundle.
- [ ] Evaluate loadable dialect plugins if static linking becomes too expensive.
- [ ] Publish signed Linux and macOS binaries and add a Mason registry package.

The authoritative registry is [mlir-lsp.cpp](mlir-lsp.cpp). Keeping the list in
the executable makes supported dialects explicit and reviewable.

## License

Apache License v2.0 with LLVM Exceptions.
