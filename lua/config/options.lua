-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.cmdheight = 0

-- Map Russian keyboard layout to English QWERTY in normal/visual modes
vim.opt.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,"
  .. "фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

-- Ensure that mapped characters trigger your custom keybinds
vim.opt.langremap = true

-- Remove hyphen from iskeyword so w and b treat it as a word boundary
vim.opt.iskeyword:remove("-")

-- Enable reading .nvim.lua files in the current directory
vim.o.exrc = true
