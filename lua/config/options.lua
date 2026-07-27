-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.cmdheight = 0

-- Russian JCUKEN → QWERTY (see lua/config/cyrillic.lua)
require("config.cyrillic").apply_langmap()
require("config.cyrillic").setup_autocmd()

-- Remove hyphen from iskeyword so w and b treat it as a word boundary
vim.opt.iskeyword:remove("-")

-- Enable reading .nvim.lua files in the current directory
vim.o.exrc = true

-- Disable appending layzgit config
vim.g.lazygit_config = false
