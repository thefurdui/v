return {
  "lewis6991/gitsigns.nvim",
  keys = {
    {
      "<leader>gd",
      function()
        vim.cmd("Gitsigns toggle_linehl")
        vim.cmd("Gitsigns toggle_deleted")
        vim.cmd("Gitsigns toggle_word_diff")
      end,
      "desc: Show inline git diff",
    },
  },
}
