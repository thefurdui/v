return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Forces LazyVim to use standard find_files instead of git_files
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
  },
  opts = {
    defaults = {
      -- This handles text searching (<leader>sg)
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden", -- Show hidden files
        "--glob=!.git/", -- Explicitly exclude the .git directory
      },
    },
    pickers = {
      -- This handles file searching (<leader>ff and <leader><space>)
      find_files = {
        find_command = { "rg", "--files", "--hidden", "--glob=!.git/" },
      },
    },
  },
}
