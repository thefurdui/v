return {
  "esmuellert/codediff.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = "CodeDiff",
  opts = {
    active_diff_algorithm = "myers", -- or "histogram"
  },
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "CodeDiff" },
  },
}
