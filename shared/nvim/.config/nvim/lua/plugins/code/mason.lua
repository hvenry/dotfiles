return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()

    -- LSP servers Mason should install (we start them ourselves in lspconfig.lua)
    require("mason-lspconfig").setup({
      ensure_installed = {
        "clangd",
        "cssls", -- css-lsp
        "emmet_ls", -- emmet-ls
        "html", -- html-lsp
        "lua_ls", -- lua-language-server
        "pyright",
        "tailwindcss", -- tailwindcss-language-server
        "ts_ls", -- typescript-language-server
        "qmlls",
      },
      automatic_installation = true,
    })

    -- Non-LSP tools (formatters/linters/aux)
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- formatters
        "stylua",
        "prettierd",
        "gofumpt",
        "goimports",
        "rustfmt",
        "sqlfmt",
        "taplo",
        "xmlformatter",
        "shfmt",
        -- linters / others
        "eslint_d",
        "golangci-lint",
        "shellcheck",
        "ruff",
      },
      run_on_start = true,
      start_delay = 0,
      debounce_hours = 24,
    })
  end,
}
