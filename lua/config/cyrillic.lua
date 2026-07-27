--- ЙЦУКЕН (JCUKEN) → QWERTY positional mapping for Russian keyboard layout.
--- Used so Normal/Visual commands and plugin keymaps work without switching layout.

local M = {}

--- @type table<string,string>
M.en_to_ru = {
  q = "й",
  w = "ц",
  e = "у",
  r = "к",
  t = "е",
  y = "н",
  u = "г",
  i = "ш",
  o = "щ",
  p = "з",
  ["["] = "х",
  ["]"] = "ъ",
  a = "ф",
  s = "ы",
  d = "в",
  f = "а",
  g = "п",
  h = "р",
  j = "о",
  k = "л",
  l = "д",
  [";"] = "ж",
  ["'"] = "э",
  z = "я",
  x = "ч",
  c = "с",
  v = "м",
  b = "и",
  n = "т",
  m = "ь",
  [","] = "б",
  ["."] = "ю",
  ["/"] = ".",
  ["`"] = "ё",
}

--- Neovim 'langmap' (see :help langmap). Letters + punctuation on the same physical keys as QWERTY.
M.langmap = table.concat({
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz",
  "ХЪ;[]",
  "хъ;[]",
  "ЖЭ;:'",
  "жэ;:'",
  ".;/",
}, ",")

local function has_cyrillic(s)
  return s:find("[\208-\209][\128-\191]") ~= nil
end

local function ru_char(ch)
  local ru = M.en_to_ru[ch] or M.en_to_ru[ch:lower()]
  if not ru then
    return ch
  end
  if ch:match("%u") and ru:len() > 0 then
    return ru:sub(1, 1):upper() .. ru:sub(2)
  end
  return ru
end

--- Translate Latin keys inside a lhs string to JCUKEN equivalents (for modifier chords).
local function translate_lhs(lhs)
  if has_cyrillic(lhs) then
    return nil
  end

  local out = {}
  local i = 1
  while i <= #lhs do
    if lhs:sub(i, i) == "<" then
      local close = lhs:find(">", i, true)
      if not close then
        return nil
      end
      local token = lhs:sub(i, close)
      local inner = token:match("^<(.-)>$")
      if inner and inner:find("^C%-") then
        local key = inner:sub(3)
        if key and #key == 1 then
          local ru = ru_char(key:lower())
          if ru ~= key and ru ~= key:lower() then
            out[#out + 1] = "<C-" .. ru .. ">"
          else
            out[#out + 1] = token
          end
        else
          out[#out + 1] = token
        end
      elseif inner and (inner:find("^A%-") or inner:find("^M%-") or inner:find("^D%-")) then
        local prefix, key = inner:match("^([AMD]%-)(.+)$")
        if key and #key == 1 then
          local ru = ru_char(key:lower())
          out[#out + 1] = "<" .. prefix .. ru .. ">"
        else
          out[#out + 1] = token
        end
      else
        out[#out + 1] = token
      end
      i = close + 1
    else
      local ch = lhs:sub(i, i)
      out[#out + 1] = ru_char(ch)
      i = i + 1
    end
  end

  local ru_lhs = table.concat(out)
  if ru_lhs == lhs then
    return nil
  end
  return ru_lhs
end

local function needs_layout_mirror(lhs)
  if lhs:find("[<][CMASD]%-") then
    return true
  end
  return false
end

function M.apply_langmap()
  vim.opt.langmap = M.langmap
  vim.opt.langremap = true
end

--- Duplicate global keymaps that use Ctrl/Alt/Meta so they match JCUKEN layout.
function M.mirror_modifier_keymaps()
  local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }
  for _, mode in ipairs(modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      if map.buffer == 0 and map.lhs and needs_layout_mirror(map.lhs) then
        local ru_lhs = translate_lhs(map.lhs)
        if ru_lhs then
          local existing_lhs = vim.fn.maparg(ru_lhs, mode, false, true).lhs
          if not existing_lhs or existing_lhs == "" then
            local opts = {
              noremap = map.noremap == 1,
              silent = map.silent == 1,
              expr = map.expr == 1,
              nowait = map.nowait == 1,
              desc = map.desc and (map.desc .. " (RU layout)") or "RU layout mirror",
            }
            if map.callback then
              vim.keymap.set(mode, ru_lhs, map.callback, opts)
            elseif map.rhs then
              vim.keymap.set(mode, ru_lhs, map.rhs, opts)
            end
          end
        end
      end
    end
  end
end

function M.setup_autocmd()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
      vim.schedule(function()
        M.mirror_modifier_keymaps()
      end)
    end,
  })
  -- LazyVim may register maps after LazyVimStarted; second pass after full startup.
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.defer_fn(function()
        M.mirror_modifier_keymaps()
      end, 500)
    end,
  })
end

return M
