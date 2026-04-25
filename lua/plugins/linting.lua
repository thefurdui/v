return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Ensure the linters table exists
      opts.linters = opts.linters or {}

      -- Configure markdownlint-cli2 (LazyVim's default for Markdown)
      opts.linters["markdownlint-cli2"] = {
        args = {
          "--config",
          vim.fn.stdpath("config") .. "/.markdownlint.json",
        },
      }

      -- Also configure standard markdownlint just in case you use that instead
      opts.linters["markdownlint"] = {
        args = {
          "--disable",
          "MD013",
          "--",
        },
      }
    end,
  },
}
