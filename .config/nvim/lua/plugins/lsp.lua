return {
  -- Install LSP servers automatically
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")

    -- Enable mason
    mason.setup()

    -- Ensure pyright is installed
    mason_lspconfig.setup({
      ensure_installed = { "pyright" },
    })

    -- Configure LSP servers
    mason_lspconfig.setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({})
      end,
    })
  end,
}
