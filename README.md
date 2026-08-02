# mlir-lsp

An opinionated MLIR LSP server.

Dialects supported:

- Built-in MLIR dialects (`affine`, `arith`, `async`, `cf`, `complex`, `dlti`,
  `func`, `gpu`, `linalg`, `llvm`, `math`, `memref`, `nvgpu`, `nvvm`, `omp`,
  `pdl`, `rocdl`, `scf`, `sparse_tensor`, `tensor`, `transform`, `ub`, and
  `vector`)
- StableHLO and related dialects (`stablehlo`, `chlo`, `mhlo`, `check`, and
  `interpreter`)
- Enzyme dialects (`enzyme` and `impulse`)
- Enzyme-XLA dialects (`enzymexla`, `comm`, `distributed`, `tessera`,
  `perfify`, and `triton_ext`)
- Shardy (`sdy`)
- Triton and CUDA Tile (`triton`, `triton_gpu`, `triton_nvidia_gpu`, and
  `cuda_tile`)

## Install

The default install path is `$HOME/.local/bin`.

```bash
curl -fsSL https://raw.githubusercontent.com/vimarsh6739/mlir-lsp/main/install.sh | bash
```

You can modify this path using `INSTALL_PREFIX`:

```bash
curl -fsSL https://raw.githubusercontent.com/vimarsh6739/mlir-lsp/main/install.sh | INSTALL_PREFIX="$HOME/bin" bash
```

## Neovim

Neovim 0.11+ with Lazy:

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

With a custom server path:

```lua
require('mlir_lsp').setup {
  cmd = { '/custom/path/mlir-lsp' },
}
```

## Visual Studio Code

Install LLVM's MLIR extension and set the server path:

```json
{
  "mlir.server_path": "/home/you/.local/bin/mlir-lsp"
}
```
