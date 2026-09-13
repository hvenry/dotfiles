return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git / goto" },
      { "<leader>h", group = "hunk" },
      { "<leader>q", group = "session" },
      { "<leader>r", group = "resize / rename" },
      { "<leader>t", group = "toggle" },
    },
  },
}
