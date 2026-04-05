local mode_map = {
  ["n"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  ["␖"] = "VISUAL BLOCK",
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  ["␓"] = "SELECT BLOCK",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
  ["nt"] = "TERMINAL",
  ["niI"] = "INSERT NORMAL",
  ["niR"] = "REPLACE NORMAL",
  ["niV"] = "VISUAL NORMAL",
}

_G.mode = function()
  local mode = vim.api.nvim_get_mode().mode
  local label = mode_map[mode] or mode:upper()
  return string.format("  %s ", label)
end

_G.branch_name = function()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  if branch ~= "" then
    return string.format("   %s", branch)
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

  return string.format("  %s ", status_message)
end

vim.api.nvim_create_autocmd('LspProgress', {
  callback = function()
    vim.api.nvim__redraw({
      statusline = true
    })
  end
})


_G.lsp_warnings = function()
  local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local count = vim.tbl_count(warnings)
  if count == 0 then
    return ""
  end
  return string.format("   %s ", count)
end

_G.lsp_errors = function()
  local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local count = vim.tbl_count(warnings)
  if count == 0 then
    return ""
  end
  return string.format("   %s ", count)
end

_G.filetype = function()
  local ft = vim.bo.filetype
  local icon = require("filetype_map").get_icon(ft)
  return string.format(" %s %s ", ft, icon):upper()
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
