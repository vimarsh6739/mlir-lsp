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

Install `bazelisk`.

```bash
git clone https://github.com/vimarsh6739/mlir-lsp.git
cd mlir-lsp && ./install.sh
```

The installer builds an optimized binary and writes it to
`~/.local/bin/mlir-lsp-server`. Override the destination when needed:

```sh
INSTALL_PREFIX="$HOME/bin" ./install.sh
```

## Neovim

Ensure you have neovim 0.12+. Install with `Lazy`

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

If you want to specify a custom lsp server

```lua
require('mlir_lsp').setup {
  lsp = {
    cmd = { '/custom/path/mlir-lsp-server' },
  },
}
```

## Visual Studio Code

Install LLVM's MLIR extension and set the server path:

```json
{
  "mlir.server_path": "/home/you/.local/bin/mlir-lsp-server"
}
```
