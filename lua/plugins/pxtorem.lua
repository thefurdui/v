return {
  "jsongerber/nvim-px-to-rem",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    root_font_size = 16,
    decimal_count = 4,
    show_virtual_text = true,
    add_cmp_source = true,
  },
  keys = {
    { "<leader>px", "<cmd>PxToRemCursor<CR>", desc = "Convert Px to Rem (Cursor)" },
    { "<leader>pl", "<cmd>PxToRemLine<CR>", desc = "Convert Px to Rem (Line)" },
  },
}
