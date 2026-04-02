return {
  "epwalsh/obsidian.nvim",
  version = "*", -- Recommended: use the latest release instead of the latest commit
  lazy = true,
  -- This is the magic part. It tells lazy.nvim to ONLY load the plugin
  -- when you open a markdown file inside this specific iCloud directory.
  -- Note the double backslash (\\) is required in Lua to escape the space in "Mobile Documents".
  event = {
    "BufReadPre ~/Users/thefurdui/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents/main/**.md",
    "BufNewFile ~/Users/thefurdui/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents/main/**.md",
  },
  dependencies = {
    -- Required dependency
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "my_vault",
        -- In the 'opts' table, you do NOT need to escape the space.
        -- Neovim handles this string normally.
        path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/YOUR_VAULT_NAME",
      },
    },

    -- Optional but recommended: configure how you want new notes to be generated
    new_notes_location = "current_dir",
    -- Optional: If you use a specific UI for completion (like nvim-cmp)
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    -- Explicitly tell obsidian.nvim to use Telescope for UI
    picker = {
      name = "telescope",
    },
  },
}
