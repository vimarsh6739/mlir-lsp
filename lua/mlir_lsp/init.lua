local M = {}

function M.setup(opts)
  opts = opts or {}

  if opts.lsp ~= false then
    local lsp = vim.tbl_deep_extend('force', {
      cmd = { vim.fn.expand('~/.local/bin/mlir-lsp-server') },
      filetypes = { 'mlir' },
      root_markers = { '.git' },
    }, opts.lsp or {})

    vim.lsp.config('mlir_lsp_server', lsp)
    vim.lsp.enable('mlir_lsp_server')
  end
end

return M
