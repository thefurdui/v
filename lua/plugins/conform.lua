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
        sql = { "sql_formatter" },
        astro = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = function(_, ctx)
            if vim.endswith(ctx.filename, ".astro") then
              return {
                "--plugin",
                vim.fn.expand("~/.config/nvim/node_modules/prettier-plugin-astro/dist/index.js"),
              }
            end
            return {}
          end,
        },
        php_cs_fixer = {
          args = {
            "fix",
            "--using-cache=no",
            "--quiet",
            "$FILENAME",
          },
        },
        sql_formatter = {
          prepend_args = { "-l", "sqlite" },
        },
      },
    },
  },
}
