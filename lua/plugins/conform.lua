return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        kdl = { "kdlfmt" },
        php = { "php_cs_fixer" },
      },
      formatters = {
        prettier = {
          -- 1. Remove "command", "args", and "stdin" lines.
          -- Conform handles the defaults automatically.
          -- 2. Use this function to decide when to inject the global config
          prepend_args = function(_, ctx)
            local config_names = {
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              ".prettierrc.cjs",
              "prettier.config.js",
              "prettier.config.cjs",
              -- Note: "package.json" is excluded to avoid false positives
            }

            -- Search upward for a local config
            local found_config = vim.fs.find(config_names, {
              upward = true,
              path = ctx.dirname,
            })

            -- If NO local config is found, use the global one
            if #found_config == 0 then
              return { "--config", vim.fn.expand("~/.config/nvim/.prettierrc") }
            end

            -- If a local config IS found, return empty (Prettier uses the local one)
            return {}
          end,
        },
        php_cs_fixer = {
          -- Replace prepend_args with a full args override
          args = {
            "fix",
            "--using-cache=no",
            "--quiet",
            "$FILENAME",
          },
        },
      },
    },
  },
}
