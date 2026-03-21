return {
  -- Configure nvim-tree.lua
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
    },
  },

  -- Configure neo-tree.nvim (LazyVim's older default) just in case
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- Configure telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.vimgrep_arguments = opts.defaults.vimgrep_arguments or {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      }

      -- Add ripgrep arguments to search hidden/gitignored files, but ignore node_modules and .git
      local extra_args = { "--hidden", "--no-ignore", "--glob=!**/.git/*", "--glob=!**/node_modules/*" }
      for _, arg in ipairs(extra_args) do
        if not vim.tbl_contains(opts.defaults.vimgrep_arguments, arg) then
          table.insert(opts.defaults.vimgrep_arguments, arg)
        end
      end

      -- Configure find_files to also show hidden/ignored but skip node_modules and .git
      opts.pickers = opts.pickers or {}
      opts.pickers.find_files = opts.pickers.find_files or {}
      opts.pickers.find_files.find_command = {
        "rg",
        "--files",
        "--hidden",
        "--no-ignore",
        "--glob=!**/.git/*",
        "--glob=!**/node_modules/*",
      }
    end,
  },

  -- Configure snacks.nvim (LazyVim's current default) just in case
  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        hidden = true,
        ignored = true,
        exclude = { "node_modules", ".git" },
      },
      explorer = {
        hidden = true,
        ignored = true,
      },
    },
  },
}
