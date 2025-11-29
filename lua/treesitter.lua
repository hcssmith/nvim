local parsers = {
  cs = "c_charp"
}


vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    local parser_name = parsers[ft] or ft

    local ok = pcall(function()
      vim.treesitter.start(buf, parser_name)
    end)

    if not ok then
      vim.schedule(function()
        vim.notify(
          "TS: No parser for " .. parser_name,
          vim.log.levels.WARN
        )
      end)
    end
  end
})
