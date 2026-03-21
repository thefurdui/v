return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    opts = {
      highlights = {
        SnacksDashboardHeader = { fg = "${orange}", bold = true },
        SnacksDashboardIcon = { fg = "${orange}" },
        SnacksDashboardSpecial = { fg = "${orange}", bold = true },
        SnacksDashboardKey = { fg = "${blue}", bold = true },
        SnacksDashboardDesc = { fg = "${fg}" },
        SnacksDashboardFooter = { fg = "${gray}" },
        SnacksDashboardDir = { fg = "${gray}" },
        SnacksDashboardFile = { fg = "${cyan}" },
      },
    },
  },

  -- Configure LazyVim to load onedarkpro
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark_vivid",
    },
  },
}
