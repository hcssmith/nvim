local branch_name = function()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  return branch
end

local function branch_exists(branch)
  local output = vim.fn.systemlist({ "git", "branch", "--list", branch })
  return #output > 0
end

vim.api.nvim_create_user_command(
  'GitPush',
  function(args)
    local branch = branch_name()
    vim.fn.system({ "git", "push", "origin", branch })
    vim.print("Pushed " .. branch .. " to origin")
  end,
  {})

vim.api.nvim_create_user_command(
  'GitPull',
  function(args)
    vim.fn.system({ "git", "pull" })
  end,
  {})

vim.api.nvim_create_user_command(
  'GitStage',
  function(args)
    local file = args.args
    if file == "" then
      file = vim.fn.expand("%")
    end
    vim.fn.system({ "git", "add", file })
    vim.print("Staged: " .. file)
  end,
  {
    nargs = "?",
    complete = "file"
  })

vim.api.nvim_create_user_command(
  "GitCommit",
  function(args)
    local message = args.args
    if message ~= "" then
      vim.fn.system({ "git", "commit", "-m", message })
    else
      local buf = vim.api.nvim_create_buf(false, true)
      local width = math.floor(vim.o.columns * 0.5)
      local height = 5
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })

      local git_status = vim.fn.split(
        vim.fn.system({ "git", "diff", "--cached", "--name-status" }),
        "\n")



      vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        git_status)


      vim.keymap.set('n', '<Esc>', function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local text = table.concat(lines, "\n")
        vim.api.nvim_win_close(win, true)
        vim.fn.system({ "git", "commit", "-m", text })
      end, {
        buffer = buf
      })
    end
  end,
  {})


vim.api.nvim_create_user_command("GitCheckout",
  function(args)
    local branch = args.args
    if branch_exists(branch) then
      vim.print("Switching to " .. branch)
      vim.fn.system({ "git", "checkout", branch })
    else
      vim.print("Creating new branch " .. branch)
      vim.fn.system({ "git", "checkout", "-b", branch })
    end
  end, {
    nargs = 1 })


vim.keymap.set("n", "<leader>gc", ":GitCommit<CR>", {})
vim.keymap.set("n", "<leader>gs", ":GitStage<CR>", {})
vim.keymap.set("n", "<leader>gp", ":GitPull<CR>", {})
vim.keymap.set("n", "<leader>gP", ":GitPush<CR>", {})
