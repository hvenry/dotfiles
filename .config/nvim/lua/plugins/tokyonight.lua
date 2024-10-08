return {
  "folke/tokyonight.nvim",
  config = function()
    require("tokyonight").setup({
      style = "night", -- This ensures `tokyonight-night` is selected
    })
    vim.cmd("colorscheme tokyonight-night") -- Set the colorscheme here
  end,
}
