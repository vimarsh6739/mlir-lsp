local M = {}

local tree_sitter_mlir_revision = '258c6cdbd7ddcfa20e7c2a2ac9e8f6e3beebf457'

local function setup_treesitter(opts)
  local group = vim.api.nvim_create_augroup('MlirLspTreeSitter', { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'TSUpdate',
    callback = function()
      require('nvim-treesitter.parsers').mlir = {
        install_info = {
          url = 'https://github.com/felixtensor/tree-sitter-mlir',
          -- Periodically update this pin to upstream HEAD, then run :TSUpdate mlir.
          revision = opts.revision,
          queries = 'queries',
        },
      }
    end,
  })

  require('nvim-treesitter').install { 'mlir' }

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'mlir',
    callback = function(event)
      pcall(vim.treesitter.start, event.buf, 'mlir')
    end,
  })
end

function M.setup(opts)
  opts = opts or {}

  if opts.lsp ~= false then
    local lsp = vim.tbl_deep_extend('force', {
      cmd = { vim.fn.expand '~/.local/bin/mlir-lsp-server' },
      filetypes = { 'mlir' },
      root_markers = { '.git' },
    }, opts.lsp or {})

    vim.lsp.config('mlir_lsp_server', lsp)
    vim.lsp.enable 'mlir_lsp_server'
  end

  if opts.treesitter ~= false then
    local treesitter = vim.tbl_deep_extend('force', {
      revision = tree_sitter_mlir_revision,
    }, opts.treesitter or {})
    setup_treesitter(treesitter)
  end
end

return M
