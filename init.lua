-- General Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.opt.path:append('**')

vim.g.mapleader = " "
vim.cmd.colorscheme("rose-pine-main")

-- General keybinds

vim.keymap.set('i', 'jk', '<Esc>')

vim.keymap.set('n', '<leader>ff', ':find ')

-- LSP Stuff
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
  "clangd"
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
      vim.opt.completeopt = "menu,noinsert,fuzzy,preview"
    end
  end,
})

local mode_map = {
  ["n"] = { "NORMAL", "Normal" },
  ["no"] = { "NORMAL", "Normal" },
  ["v"] = { "VISUAL", "Visual" },
  ["V"] = { "VISUAL LINE", "Visual" },
  ["␖"] = { "VISUAL BLOCK", "Visual" },
  ["s"] = { "SELECT", "Select" },
  ["S"] = { "SELECT LINE", "Select" },
  ["␓"] = { "SELECT BLOCK", "Select" },
  ["i"] = { "INSERT", "Insert" },
  ["ic"] = { "INSERT", "Insert" },
  ["R"] = { "REPLACE", "Replace" },
  ["Rv"] = { "VISUAL REPLACE", "Replace" },
  ["c"] = { "COMMAND", "Command" },
  ["cv"] = { "VIM EX", "Command" },
  ["ce"] = { "EX", "Command" },
  ["r"] = { "PROMPT", "Normal" },
  ["rm"] = { "MOAR", "Normal" },
  ["r?"] = { "CONFIRM", "Normal" },
  ["!"] = { "SHELL", "Normal" },
  ["t"] = { "TERMINAL", "Normal" },
  ["nt"] = { "TERMINAL", "Normal" }
}

_G.mode = function()
  local mode = vim.api.nvim_get_mode().mode
  local highlight = "%#" .. mode_map[mode][2] .. "#%"
  local reset = "%#StatusDefault#%"
  return string.format("%s  %s %s ", highlight, mode_map[mode][1], reset)
end

_G.branch_name = function()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  local hi = "%#DiagnosticInfo#%"
  if branch ~= "" then
    return string.format("  %s  %s", hi, branch)
  else
    return ""
  end
end

_G.lsp_progress = {}

_G.lsp_status = function()
  -- Check if lsp running on current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local status_message = ""
  local ccount = 0
  if #clients > 0 then
    for _, client in pairs(clients) do
      ccount = ccount + 1
      if ccount > 1 then
        status_message = status_message .. " - "
      end
      local progress = client.progress:pop()
      if progress == nil then
        status_message = client.name
        break
      end
      if progress.value == nil then
        break
      end
      if progress.value.kind == "begin" then
        lsp_progress[progress.token] = "begin"
      end
      if progress.value.kind == "end" then
        lsp_progress[progress.token] = "end"
      end
      local title = progress.value.title or ""
      local msg = progress.value.message or ""
      if title == "Loading workspace" and msg == "" then
        title = client.name
        if lsp_progress[progress.token] == "begin" then
          lsp_progress[progress.token] = "end"
        end
      end
      if lsp_progress[progress.token] == "end" then
        title = client.name
        msg = ""
      end
      status_message = status_message .. title .. " " .. msg
    end
  else
    return ""
  end
  local hi = "%#DiagnosticOk#%"
  local reset = "%#StatusDefault#%"

  return string.format("%s %s %s ", hi, status_message, reset)
end

vim.api.nvim_create_autocmd('LspProgress', {
  callback = function()
    vim.api.nvim__redraw({
      statusline = true
    })
  end
})


_G.lsp_warnings = function()
  -- get number of lsp warnings in feed
  local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local count = vim.tbl_count(warnings)
  local hi = "%#DiagnosticWarn#%"
  local reset = "%#StatusDefault#%"
  if count == 0 then
    return ""
  end
  return string.format("%s > %s %s ", hi, count, reset)
end

_G.lsp_errors = function()
  -- get number of lsp errors in feed
  local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local count = vim.tbl_count(warnings)
  local hi = "%#DiagnosticError#%"
  local reset = "%#StatusDefault#%"
  if count == 0 then
    return ""
  end
  return string.format("%s !! %s %s ", hi, count, reset)
end

_G.filetype = function()
  return string.format(" %s ", vim.bo.filetype):upper()
end

_G.lineinfo = function()
  if vim.bo.filetype == "alpha" then
    return ""
  end
  return " %P %l:%c "
end


local status = {
  '%{%v:lua.branch_name()%}',
  '%{%v:lua.mode()%}',
  '%t',
  '%{%v:lua.lsp_status()%}',
  '%{%v:lua.lsp_warnings()%}',
  '%{%v:lua.lsp_errors()%}',
  '%=',
  '%{%v:lua.filetype()%}',
  '%{%v:lua.lineinfo()%}',
}

vim.o.statusline = table.concat(status, ' ')
vim.o.laststatus = 3
