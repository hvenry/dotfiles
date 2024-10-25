return {
  "nvim-telescope/telescope-frecency.nvim",
  dependencies = { "tami5/sqlite.lua" },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      extensions = {
        frecency = {
          default_workspace = "CWD",
          show_scores = false,
          ignore_patterns = { "*.git/*", "*/tmp/*" },
        },
      },
    })
    telescope.load_extension("frecency")
  end,
}
