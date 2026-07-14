return {
  -- Disable noice.nvim
  { "folke/noice.nvim", enabled = false },

  -- Configure snacks.nvim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = function(_, opts)
      opts = opts or {}

      opts.bigfile = { enabled = true }
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.enabled = true
      opts.dashboard.preset = vim.tbl_deep_extend("force", opts.dashboard.preset or {}, {
        header = [[
 █████   █████
▒▒███   ▒▒███ 
 ▒███    ▒███ 
 ▒███    ▒███ 
 ▒▒███   ███  
  ▒▒▒█████▒   
    ▒▒███     
     ▒▒▒      ]],
      })

      opts.indent = { enabled = true }
      opts.input = { enabled = true }
      opts.notifier = {
        enabled = true,
        timeout = 3000,
      }
      opts.quickfile = { enabled = true }
      opts.scroll = { enabled = true }
      opts.statuscolumn = { enabled = true }
      opts.lazygit = opts.lazygit or {}
      opts.lazygit.configure = false
      opts.words = vim.tbl_deep_extend("force", opts.words or {}, {
        filter = function(buf)
          if vim.g.snacks_words == false or vim.b[buf].snacks_words == false then
            return false
          end
          local ft = vim.bo[buf].filetype
          if ft == "markdown" or ft == "markdown.mdx" or vim.b[buf].obsidian_buffer then
            return false
          end
          return true
        end,
      })
      opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, {
        replace_netrw = false,
      })

      -- Inline images in vault markdown (obsidian.nvim + Kitty graphics terminal)
      opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
        enabled = true,
        doc = {
          enabled = true,
          inline = true,
        },
        resolve = function(path, src)
          local ok, api = pcall(require, "obsidian.api")
          if ok and api.path_is_note(path) then
            return api.resolve_attachment_path(src)
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>n",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification History",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
    },
  },
}
