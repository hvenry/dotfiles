return {
  -- theme
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- line width
  {
    "lukas-reineke/virt-column.nvim",
    opts = {
      char = { "┆" },
      virtcolumn = "120",
      highlight = { "NonText" },
    },
  },
  -- remove scroll animation
  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
}
