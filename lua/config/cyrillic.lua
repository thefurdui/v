--- JCUKEN (ЙЦУКЕН) ↔ QWERTY layout helpers for Neovim.
--- 'langmap' covers Normal/Visual motion keys. Modifier chords and
--- plugin maps need langmapper.nvim (see lua/plugins/langmapper.lua).

local M = {}

local function escape(str)
  -- langmap special chars: ; , " | \
  return vim.fn.escape(str, [[;,."|\]])
end

-- Physical-key parallel strings (same length / order).
-- See :help langmap and Wansmer/langmapper README.
local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm,./]]
local ru = [[ёйцукенгшщзхъфывапролджэячсмитьбю.]]
local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?]]
local ru_shift = [[ËЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,]]

--- Apply a complete JCUKEN langmap (letters + punctuation).
function M.apply_langmap()
  vim.opt.langmap = vim.fn.join({
    -- `to` first, `from` second: Cyrillic keypress → Latin meaning
    escape(ru_shift) .. ";" .. escape(en_shift),
    escape(ru) .. ";" .. escape(en),
  }, ",")
  -- MUST stay off with langmapper: on + remapping feedkeys can recurse
  -- and explode the typeahead/remap stack (multi‑GB compressor/swap).
  vim.opt.langremap = false
end

--- Layout strings for langmapper.nvim (must match default_layout length).
M.langmapper = {
  -- Apple "Russian" (not RussianWin). KeyboardLayout ID 19456.
  id = "com.apple.keylayout.Russian",
  -- Same glyph order as langmapper default_layout:
  -- ABCDEFGHIJKLMNOPQRSTUVWXYZ<>:"{}~abcdefghijklmnopqrstuvwxyz,.;'[]`
  layout = [[ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯБЮЖЭХЪЁфисвуапршолдьтщзйкыегмцчнябюжэхъё]],
  default_layout = [[ABCDEFGHIJKLMNOPQRSTUVWXYZ<>:"{}~abcdefghijklmnopqrstuvwxyz,.;'[]`]],
}

return M
