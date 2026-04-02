return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Only load the plugin when you start typing
  dependencies = {
    -- 1. Snippet Engine (Required by nvim-cmp)
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",

    -- 2. Helpful Completion Sources
    "hrsh7th/cmp-buffer", -- Completes words from the current file
    "hrsh7th/cmp-path", -- Completes file paths (like /Users/name/...)

    -- (Note: If you write code, you'll eventually want "hrsh7th/cmp-nvim-lsp" here too)
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      -- Tell cmp to use LuaSnip for expanding snippets
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- Set up your keybindings
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item

        -- Use Tab and Shift-Tab to navigate the completion menu
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      -- Define where cmp should get its suggestions from
      -- Order matters! The sources at the top have higher priority.
      sources = cmp.config.sources({
        -- obsidian.nvim automatically injects itself here, but we add these
        -- fallbacks for regular typing and other files:
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
