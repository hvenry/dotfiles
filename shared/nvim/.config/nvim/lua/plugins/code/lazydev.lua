-- Teaches lua_ls the Neovim API while editing this config.
-- Note: lazydev manages workspace.library itself, so don't set it in lspconfig.
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
