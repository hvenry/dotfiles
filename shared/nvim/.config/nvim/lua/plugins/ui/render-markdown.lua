return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  -- Needs the markdown + markdown_inline treesitter parsers (see
  -- plugins/code/treesitter.lua) - without them it loads but renders nothing.
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Un-render only the line the cursor is on, so editing never fights the
    -- rendering. This is the behaviour that makes it usable while writing.
    anti_conceal = { enabled = true },
    heading = {
      -- No sign column clutter; the heading background is enough.
      sign = false,
    },
    code = {
      sign = false,
      -- Pad the block out to the window edge so it reads as a solid block.
      width = "block",
      right_pad = 2,
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    vim.keymap.set("n", "<leader>tm", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown rendering" })
  end,
}
