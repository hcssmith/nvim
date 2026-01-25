local M = {}

local http = require("http")

-- Get visually selected text
local function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)

  lines[1] = string.sub(lines[1], s_start[3], -1)
  local last_line_idx = #lines
  if n_lines > 1 then
    lines[last_line_idx] = string.sub(lines[last_line_idx], 1, s_end[3])
  end

  return table.concat(lines, "\n")
end

-- Replace visual selection with text
local function replace_visual_selection(new_text)
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local start_line = s_start[2] - 1
  local end_line = s_end[2]
  local start_col = s_start[3] - 1
  local end_col = s_end[3]

  -- Split new text into lines
  local new_lines = vim.split(new_text, "\n", { plain = true })

  -- Handle partial line at start
  if #new_lines > 0 then
    new_lines[1] = vim.api.nvim_buf_get_lines(0, start_line, start_line + 1, false)[1]:sub(1, start_col) .. new_lines[1]
  end

  -- Handle partial line at end
  if #new_lines > 0 and s_end[2] ~= s_start[2] then
    local end_line_content = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1]
    new_lines[#new_lines] = new_lines[#new_lines] .. end_line_content:sub(end_col + 1)
  end

  -- Replace lines
  vim.api.nvim_buf_set_lines(0, start_line, end_line, false, new_lines)
end

-- Send prompt to opencode server
local function send_to_opencode(prompt, code, callback)
  local server_url = os.getenv("OPENCODE_SERVER_URL") or "http://localhost:4096"

  -- Check if server is running
  http.get(server_url .. "/global/health", function(body, err)
    if err then
      callback(nil, "Opencode server not running at " .. server_url .. ". Run: opencode serve")
      return
    end

    -- Try to get current session, or create a new one
    http.get(server_url .. "/session/current", function(session_body, session_err)
      local session_id

      if session_err then
        -- Create a new session
        vim.notify("Creating new session...", vim.log.levels.INFO)
        http.post(server_url .. "/session", {}, function(create_body, create_err)
          if create_err then
            callback(nil, "Failed to create session: " .. tostring(create_err))
            return
          end

          local create_ok, create_data = pcall(vim.fn.json_decode, create_body)
          if not create_ok or not create_data or not create_data.id then
            callback(nil, "Failed to parse session: " .. create_body)
            return
          end

          session_id = create_data.id
          vim.notify("Created new session: " .. session_id, vim.log.levels.INFO)
          send_message(session_id, prompt, code, server_url, callback)
        end)
        return
      end

      local ok, session_data = pcall(vim.fn.json_decode, session_body)
      if ok and session_data and session_data.id and string.find(session_data.id, "^ses") then
        session_id = session_data.id
        vim.notify("Using existing session: " .. session_id, vim.log.levels.DEBUG)
      else
        -- Create a new session if current one is invalid
        vim.notify("Creating new session...", vim.log.levels.INFO)
        http.post(server_url .. "/session", {}, function(create_body, create_err)
          if create_err then
            callback(nil, "Failed to create session: " .. tostring(create_err))
            return
          end

          local create_ok, create_data = pcall(vim.fn.json_decode, create_body)
          if not create_ok or not create_data or not create_data.id then
            callback(nil, "Failed to parse session: " .. create_body)
            return
          end

          session_id = create_data.id
          vim.notify("Created new session: " .. session_id, vim.log.levels.INFO)
          send_message(session_id, prompt, code, server_url, callback)
        end)
        return
      end

      send_message(session_id, prompt, code, server_url, callback)
    end)
  end)
end

-- Send message to session
local function send_message(session_id, prompt, code, server_url, callback)
  local full_prompt = string.format("Here is some code:\n\n```%s\n%s\n```\n\n%s", vim.bo.filetype or "text", code, prompt)

  local payload = {
    parts = {
      { type = "text", text = full_prompt }
    }
  }

  http.post(server_url .. "/session/" .. session_id .. "/message", payload, function(response_body, err)
    if err then
      callback(nil, "Failed to send message: " .. tostring(err))
      return
    end

    -- Parse AI response
    local response_ok, response_data = pcall(vim.fn.json_decode, response_body)
    local ai_text

    if response_ok and response_data then
      if response_data.parts then
        for _, part in ipairs(response_data.parts) do
          if part.type == "text" and part.text then
            ai_text = (ai_text or "") .. part.text
          end
        end
      end
    end

    callback(ai_text or "No response from opencode", nil)
  end)
end

function test_func(x)
  return x
end

-- Debug function to check server response
_G.llm_debug = function()
  local server_url = os.getenv("OPENCODE_SERVER_URL") or "http://localhost:4096"

  -- Get current session
  http.get(server_url .. "/session/current", function(session_body, err)
    if err then
      vim.notify("Error getting session: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    vim.notify("Current session: " .. session_body, vim.log.levels.DEBUG)

    -- Try to parse
    local ok, session_data = pcall(vim.fn.json_decode, session_body)
    if ok then
      vim.print("Parsed session data:")
      vim.print(vim.inspect(session_data))
    else
      vim.notify("Failed to parse session data, trying to create new session...", vim.log.levels.WARN)

      -- Create a new session
      http.post(server_url .. "/session", {}, function(create_body, create_err)
        if create_err then
          vim.notify("Error creating session: " .. tostring(create_err), vim.log.levels.ERROR)
          return
        end

        vim.notify("Create session response: " .. create_body, vim.log.levels.DEBUG)

        local create_ok, create_data = pcall(vim.fn.json_decode, create_body)
        if create_ok then
          vim.print("Created session:")
          vim.print(vim.inspect(create_data))
        end
      end)
    end
  end)
end

-- Main function
_G.llm_replace = function()
  -- Check if we're in visual mode
  if vim.fn.mode() ~= "v" and vim.fn.mode() ~= "V" and vim.fn.mode() ~= "<C-v>" then
    vim.notify("Please select text in visual mode first", vim.log.levels.ERROR)
    return
  end

  -- Get selected text FIRST (before exiting visual mode)
  local selected_text = get_visual_selection()
  if not selected_text or selected_text == "" then
    vim.notify("No text selected", vim.log.levels.ERROR)
    return
  end

  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

  -- Schedule the prompt to run after mode change
  vim.schedule(function()
    vim.ui.input({ prompt = "Prompt: " }, function(input)
      if not input or input == "" then
        vim.notify("No prompt provided", vim.log.levels.WARN)
        return
      end

      -- Show loading message
      vim.notify("Sending to opencode... (this may take a moment)", vim.log.levels.INFO)

      -- Send to opencode and get response via callback
      send_to_opencode(input, selected_text, function(result, err)
        if err then
          vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
          return
        end

        -- Replace selection with response
        replace_visual_selection(result)
        vim.notify("Replaced with opencode response", vim.log.levels.INFO)
      end)
    end)
  end)
end

-- Set up key mapping
vim.keymap.set("v", "<leader>ov", _G.llm_replace, { desc = "Replace selection with opencode response" })
M.llm_replace = _G.llm_replace
vim.notify("llm.lua loaded - use <leader>ov in visual mode, run :lua llm_debug() to debug", vim.log.levels.INFO)

return M
