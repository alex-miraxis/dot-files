-- Follow the Arch system theme (set by `archy theme set`).
local theme = vim.fn.expand("~/.config/archy/current/theme/neovim.lua")
if (vim.uv or vim.loop).fs_stat(theme) then
  return dofile(theme)
end
return { { "folke/tokyonight.nvim", lazy = true } }
