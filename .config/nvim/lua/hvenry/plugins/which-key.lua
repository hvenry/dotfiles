return {
  "folke/which-key.nvim",
  -- we can lazy load this since it is not important
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,

  opts = {
    -- use default config
  }
}
