local M = {}

local uv = vim.loop

-- Parse URL into components
local function parse_url(url)
  local scheme = url:match("^(https?)://") or "http"
  local host = url:match("^[^:]+://([^/:]+)")
  local port_str = url:match("^[^:]+://[^:]+:(%d+)")
  local port = tonumber(port_str) or (scheme == "https" and 443 or 80)
  local path = url:match("^[^:]+://[^/]+(/.*)") or "/"
  
  return {
    scheme = scheme,
    host = host,
    port = port,
    path = path
  }
end

-- Build HTTP request
local function build_request(method, parsed_url, headers, body)
  local body_text = body or ""
  local request_lines = {
    method .. " " .. parsed_url.path .. " HTTP/1.1",
    "Host: " .. parsed_url.host,
    "Connection: close"
  }
  
  -- Add custom headers
  if headers then
    for key, value in pairs(headers) do
      table.insert(request_lines, key .. ": " .. tostring(value))
    end
  end
  
  -- Add Content-Length if body present
  if body_text ~= "" then
    table.insert(request_lines, "Content-Length: " .. #body_text)
  end
  
  table.insert(request_lines, "")
  table.insert(request_lines, body_text)
  
  return table.concat(request_lines, "\r\n")
end

-- Parse HTTP response
local function parse_response(response_text)
  local _, body = response_text:match("(.*)\r\n\r\n(.*)")
  return body or ""
end

-- Core HTTP request function
local function http_request(method, url, body, headers, callback)
  local parsed_url = parse_url(url)
  local client = uv.new_tcp()
  local response = ""
  local error_handled = false
  
  local function handle_error(err)
    if error_handled then return end
    error_handled = true
    client:close()
    callback(nil, err)
  end
  
  client:connect(parsed_url.host, parsed_url.port, function(err)
    if err then
      handle_error(err)
      return
    end
    
    local request = build_request(method, parsed_url, headers, body)
    
    client:write(request, function(werr)
      if werr then
        handle_error(werr)
        return
      end
    end)
  end)
  
  -- Read response
  client:read_start(function(rerr, chunk)
    if rerr then
      handle_error(rerr)
      return
    end
    
    if chunk then
      response = response .. chunk
    else
      -- Connection closed - parse response
      client:close()
      local body = parse_response(response)
      callback(body, nil)
    end
  end)
end

-- Convenience methods
function M.get(url, headers, callback)
  if type(headers) == "function" then
    callback = headers
    headers = nil
  end
  http_request("GET", url, nil, headers, callback)
end

function M.post(url, body, headers, callback)
  if type(headers) == "function" then
    callback = headers
    headers = nil
  end
  
  local body_text = type(body) == "table" and vim.fn.json_encode(body) or body
  local final_headers = headers or {}
  
  -- Set Content-Type if not provided and body is table
  if type(body) == "table" and not final_headers["Content-Type"] then
    final_headers["Content-Type"] = "application/json"
  end
  
  http_request("POST", url, body_text, final_headers, callback)
end

function M.put(url, body, headers, callback)
  if type(headers) == "function" then
    callback = headers
    headers = nil
  end
  
  local body_text = type(body) == "table" and vim.fn.json_encode(body) or body
  local final_headers = headers or {}
  
  if type(body) == "table" and not final_headers["Content-Type"] then
    final_headers["Content-Type"] = "application/json"
  end
  
  http_request("PUT", url, body_text, final_headers, callback)
end

function M.patch(url, body, headers, callback)
  if type(headers) == "function" then
    callback = headers
    headers = nil
  end
  
  local body_text = type(body) == "table" and vim.fn.json_encode(body) or body
  local final_headers = headers or {}
  
  if type(body) == "table" and not final_headers["Content-Type"] then
    final_headers["Content-Type"] = "application/json"
  end
  
  http_request("PATCH", url, body_text, final_headers, callback)
end

function M.delete(url, headers, callback)
  if type(headers) == "function" then
    callback = headers
    headers = nil
  end
  http_request("DELETE", url, nil, headers, callback)
end

function M.request(method, url, options, callback)
  local body = options and options.body
  local headers = options and options.headers
  http_request(method, url, body, headers, callback)
end

return M
