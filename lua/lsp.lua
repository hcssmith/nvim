vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.WARN] = ''
    }
  }
})
vim.keymap.set('n', "<leader>d", function()
  if vim.diagnostic.config().virtual_lines then
    vim.diagnostic.config({ virtual_lines = false })
  else
    vim.diagnostic.config({ virtual_lines = { current_line = true } })
  end
end)




vim.lsp.enable({
  "luals",
  "clangd",
  "bashls",
  "ols",
  "csharp_ls"
})

---@param client vim.lsp.Client
---@param bufnr integer
---@param modes string|string[]
---@param lhs string
---@param rhs function
---@param method string
local function map_if_supported(client, bufnr, modes, lhs, rhs, method)
  if not client:supports_method(method) then
    return
  end

  vim.keymap.set(modes, lhs, rhs, {
    buffer = bufnr,
    silent = true,
  })
end

---@param client vim.lsp.Client
---@param method string
---@param fn fun()
local function enable_if_supported(client, method, fn)
  if client:supports_method(method) then
    fn()
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf

    client.server_capabilities.semanticTokensProvider = nil
    enable_if_supported(client, 'textDocument/inlayHint', function()
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end)
    enable_if_supported(client, 'textDocument/completion', function()
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      vim.opt.completeopt = "menu,noinsert,fuzzy"
    end)

    map_if_supported(client, bufnr, 'n', '<leader>lf', vim.lsp.buf.format, 'textDocument/formatting')
    map_if_supported(client, bufnr, 'n', 'gd', vim.lsp.buf.definition, 'textDocument/definition')
    map_if_supported(client, bufnr, 'n', 'gD', vim.lsp.buf.declaration, 'textDocument/declaration')
    map_if_supported(client, bufnr, 'n', 'gi', vim.lsp.buf.implementation, 'textDocument/implementation')
    map_if_supported(client, bufnr, 'n', 'gy', vim.lsp.buf.type_definition, 'textDocument/typeDefinition')
    map_if_supported(client, bufnr, 'n', 'K', vim.lsp.buf.hover, 'textDocument/hover')
    map_if_supported(client, bufnr, 'i', '<C-k>', vim.lsp.buf.signature_help, 'textDocument/signatureHelp')
    map_if_supported(client, bufnr, 'n', 'gr', vim.lsp.buf.references, 'textDocument/references')
    map_if_supported(client, bufnr, 'n', 'rn', vim.lsp.buf.rename, 'textDocument/rename')

  end,
})
