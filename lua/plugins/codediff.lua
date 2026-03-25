return {
  "esmuellert/codediff.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = "CodeDiff",
  opts = {
    diff = {
      layout = "inline",
    },
  },
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "CodeDiff" },
  },
}
