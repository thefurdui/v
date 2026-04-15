return {
  {
    "yelog/i18n.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-telescope/telescope.nvim" },
    -- Keep your cmds
    cmd = { "I18nEnable", "I18nAddKey", "I18nShowTranslations" },

    -- ADD THIS BLOCK:
    keys = {
      -- 1. The "Edit" workflow: Jump directly to the JSON key
      {
        "<leader>ie",
        function()
          require("i18n").i18n_definition()
        end,
        desc = "i18n: Edit translation (Jump)",
      },

      -- 2. The "Hover" workflow: Peek at the translations like VS Code
      { "<leader>ip", "<cmd>I18nShowTranslations<CR>", desc = "i18n: Peek translations popup" },
    },

    config = function()
      local project_opts = vim.g.local_i18n_config or {}
      require("i18n").setup(project_opts)
    end,
  },
}
