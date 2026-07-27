-- Layout-independent keymaps for JCUKEN (Russian) input.
-- Built-in 'langmap' does not cover Ctrl/Alt chords or most plugin maps.
-- See: https://github.com/Wansmer/langmapper.nvim
-- See: https://github.com/neovim/neovim/issues/11971

local function patch_which_key()
  local ok_lm, lmu = pcall(require, "langmapper.utils")
  local ok_wk, wk_state = pcall(require, "which-key.state")
  if not (ok_lm and ok_wk) or wk_state._langmapper_patched then
    return
  end
  wk_state._langmapper_patched = true
  local check_orig = wk_state.check
  ---@diagnostic disable-next-line: duplicate-set-field
  wk_state.check = function(state, key)
    if key ~= nil then
      key = lmu.translate_keycode(key, "default", "ru")
    end
    return check_orig(state, key)
  end
end

local function patch_snacks()
  local ok_lm, lmu = pcall(require, "langmapper.utils")
  if not ok_lm or not Snacks or not Snacks.util or Snacks.util._langmapper_patched then
    return
  end
  Snacks.util._langmapper_patched = true
  local normkey_orig = Snacks.util.normkey
  Snacks.util.normkey = function(key)
    if key then
      key = lmu.translate_keycode(key, "default", "ru")
    end
    return normkey_orig(key)
  end
end

return {
  {
    "Wansmer/langmapper.nvim",
    lazy = false,
    -- Higher than LazyVim (10000) so hack_keymap wraps APIs before other start plugins.
    priority = 10001,
    config = function()
      local cyr = require("config.cyrillic")
      local lm = require("langmapper")

      lm.setup({
        map_all_ctrl = true,
        -- Skip insert: completion engines + leader-as-space fight Ctrl remaps there.
        ctrl_map_modes = { "n", "o", "c", "t", "v" },
        hack_keymap = true,
        disable_hack_modes = { "i" },
        automapping_modes = { "n", "v", "x", "s" },
        default_layout = cyr.langmapper.default_layout,
        layouts = {
          ru = {
            id = cyr.langmapper.id,
            layout = cyr.langmapper.layout,
            default_layout = cyr.langmapper.default_layout,
          },
        },
      })

      -- Hide translated maps from which-key / blink / cmp get_keymap callers.
      -- Without this, plugins re-process LM duplicates and can balloon state.
      lm.hack_get_keymap()

      -- With hack_keymap, one late pass is enough for builtin/vimscript maps.
      -- Do NOT also enable buffer automapping: it adds BufWinEnter/LspAttach
      -- handlers that re-scan every buffer forever.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          vim.schedule(function()
            lm.automapping({ global = true, buffer = false })
            patch_which_key()
            patch_snacks()
          end)
        end,
      })
    end,
  },
}
