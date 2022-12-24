require("functions.exists")
function Isdir(path)
  return Exists(path.."/")
end
