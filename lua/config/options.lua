-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.cmdheight = 0

-- Russian JCUKEN → QWERTY for Normal/Visual (chords via langmapper.nvim)
require("config.cyrillic").apply_langmap()

-- Remove hyphen from iskeyword so w and b treat it as a word boundary
vim.opt.iskeyword:remove("-")

-- Enable reading .nvim.lua files in the current directory
vim.o.exrc = true

-- Disable appending layzgit config
vim.g.lazygit_config = false
