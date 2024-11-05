return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "clangd" },
    })
  end,
}
