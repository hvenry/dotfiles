return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" }, -- Required dependency
  config = function()
    require("telescope").setup({
      extensions = {
        file_browser = {
          theme = "ivy",
        },
      },
    })
    require("telescope").load_extension("file_browser") -- Ensure file_browser is loaded
    require("telescope").load_extension("frecency") -- Ensure frecency is loaded
  end,
}
