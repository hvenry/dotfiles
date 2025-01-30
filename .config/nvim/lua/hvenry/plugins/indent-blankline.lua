return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  -- how lazy.nvim requires the main module
  main = "ibl",
  opts = {
    indent = { char = "┊" },
  },
}
