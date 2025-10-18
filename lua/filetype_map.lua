local filetype_icons = {
  -- Programming languages
  lua        = "",
  python     = "",
  javascript = "",
  typescript = "",
  ts         = "",
  tsx        = "",
  jsx        = "",
  html       = "",
  css        = "",
  scss       = "",
  json       = "",
  rust       = "",
  go         = "",
  c          = "",
  cpp        = "",
  h          = "",
  java       = "",
  kotlin     = "",
  sh         = "",
  bash       = "",
  zsh        = "",
  fish       = "",
  ruby       = "",
  php        = "",
  dart       = "",
  scala      = "",
  r          = "",
  ocaml      = "λ",
  elixir     = "",
  erl        = "",
  haskell    = "λ",
  zig        = "",
  make       = "",
  -- Markup / config / text
  markdown   = "",
  txt        = "",
  vim        = "",
  vimdoc     = "",
  conf       = "",
  ini        = "",
  gitconfig  = "",
  dockerfile = "",
  yaml       = "",
  toml       = "",
  csv        = "",
  sql        = "",
  graphql    = "ﰩ",
  protobuf   = "",

  -- Version control / misc
  gitcommit  = "",
  gitrebase  = "",
  diff       = "",
  log        = "",

  -- LaTeX / documentation
  tex        = "ﭨ",
  bib        = "ﭨ",

  -- Image / binary
  png        = "",
  jpg        = "",
  jpeg       = "",
  svg        = "ﰟ",
  exe        = "",
  out        = "",
}

-- default function to get icon
local M = {}
M.get_icon = function(ft)
  return filetype_icons[ft] or "" -- default icon
end

return M
