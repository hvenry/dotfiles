return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "bashls",
        "clangd",
        "cssls",
        "docker_compose_language_service",
        "dockerls",
        "emmet_ls",
        "eslint",
        "graphql",
        "hls",
        "html",
        "jdtls",
        "jsonls",
        "lua_ls",
        "marksman",
        "prismals",
        "rust_analyzer",
        "sqlls",
        "svelte",
        "tailwindcss",
        "taplo",
        "terraformls",
        "ts_ls",
        "yamlls",
      },
      automatic_installation = { true },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- Linteres
        "eslint_d",
        "flake8",
        "hadolint",
        "markdownlint-cli2",
        "pylint",
        "shellcheck",
        "tflint",
        "sqlfluff",

        -- Formatters
        "gofumpt",
        "goimports",
        "prettier",
        "shfmt",
        "stylua",

        -- Debuggers
        "codelldb",

        -- Other Tools
        "markdown-toc",
      },
    })
  end,
}
