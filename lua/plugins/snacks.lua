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
      opts.words = { enabled = true }
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
