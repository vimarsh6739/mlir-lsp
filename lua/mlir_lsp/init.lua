local M = {}

function M.setup(opts)
  local defaults = {
    cmd = { 'mlir-lsp' },
    filetypes = { 'mlir' },
    workspace_required = false,
    root_markers = { '.git' },
  }

  vim.lsp.config('mlir_lsp', vim.tbl_deep_extend('force', defaults, opts or {}))
  vim.lsp.enable('mlir_lsp')
end

return M
