
local branch_name = function()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  local hi = "%#DiagnosticInfo#%"
  if branch ~= "" then
    return string.format("%s   %s", hi, branch)
  else
    return ""
  end
end


vim.api.nvim_create_user_command(
  'GitPush',
  function(args)
    local branch = branch_name()
    vim.fn.system({"git", "push", "origin", branch})
    vim.print("Pushed " .. branch .. "to origin")
  end,
{
  nargs = 0
})

vim.api.nvim_create_user_command(
  'GitStage',
  function(args)
    local file = args.args
    if file == "" then
      file = vim.fn.expand("%")
    end
    vim.fn.system({"git", "add", file})
    vim.print("Staged: " .. file)
  end,
{
  nargs = "?",
  complete = "file"
})
