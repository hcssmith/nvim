vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '!!',
      [vim.diagnostic.severity.HINT] = '?',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.WARN] = '>'
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
  "bashls"
})
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    client.server_capabilities.semanticTokensProvider = nil
    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true)
    end
    if client:supports_method('textDocument/formatting') then
      vim.keymap.set("n", '<leader>lf', vim.lsp.buf.format, { buffer = args.buf })
      vim.api.nvim_create_autocmd('InsertLeave', {
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      vim.opt.completeopt = "menu,noinsert,fuzzy"
    end
  end,
})
