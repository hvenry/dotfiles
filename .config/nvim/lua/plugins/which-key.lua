return {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup({
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "center",
      },
    })
  end,
}
