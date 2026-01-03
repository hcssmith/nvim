local function find_dotnet_workspace()
  -- Prefer solution
  local sln = vim.fs.find(function(name)
    return name:match('%.sln$') ~= nil
  end, { upward = true })[1]

  if sln then
    return sln
  end

  -- Fallback to project
  local csproj = vim.fs.find(function(name)
    return name:match('%.csproj$') ~= nil
  end, { upward = true })[1]

  return csproj
end

vim.keymap.set('n', '<leader>lf', function()
  local workspace = find_dotnet_workspace()

  if not workspace then
    vim.notify(
      'No .sln or .csproj found for dotnet format',
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify(
    'Running dotnet format on ' .. vim.fn.fnamemodify(workspace, ':t'),
    vim.log.levels.INFO
  )

  vim.system(
    { 'dotnet', 'format', workspace },
    { text = true },
    function(result)
      if result.code ~= 0 then
        vim.notify(
          'dotnet format failed:\n' .. (result.stderr or ''),
          vim.log.levels.ERROR
        )
        return
      end

      vim.schedule(function()
        -- Reload files changed on disk
        vim.cmd('checktime')

        -- Restart C# LSP clients to refresh analyzers / formatting
        for _, client in ipairs(vim.lsp.get_clients({
          name = 'csharp_ls' })) do
          if client:supports_method('workspace/didChangeConfiguration') then
            client:notify('workspace/didChangeConfiguration', { settings = {} })
          else
            client:stop() -- fallback
          end
        end

        vim.notify('dotnet format complete', vim.log.levels.INFO)
      end)
    end
  )
end, {
  desc = 'dotnet format (prefer .sln)',
  buffer = 0
})

