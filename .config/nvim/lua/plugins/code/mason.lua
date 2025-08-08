return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "pyright", "ts_ls", "tailwindcss", "html", "cssls", "emmet_ls" },
      handlers = {
        function(server_name)
          local lspconfig = require("lspconfig")
          lspconfig[server_name].setup({ capabilities = capabilities })
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({ capabilities = capabilities })
        end,
        ["emmet_ls"] = function()
          require("lspconfig").emmet_ls.setup({
            capabilities = capabilities,
            filetypes = {
              "html",
              "css",
              "scss",
              "sass",
              "less",
              "javascriptreact",
              "typescriptreact",
              "vue",
              "svelte",
            },
          })
        end,
        ["pyright"] = function()
          local lspconfig = require("lspconfig")
          local util = require("lspconfig.util")
          lspconfig.pyright.setup({
            capabilities = capabilities,
            root_dir = util.root_pattern(
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              "Pipfile",
              "pyrightconfig.json",
              ".git"
            ),
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  autoImportCompletions = true,
                },
              },
            },
          })
        end,
      },
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- Formatters
        "stylua", -- Lua
        "prettierd", -- JS/TS/HTML/CSS/JSON/YAML/Markdown
        "gofumpt", -- Go formatting
        "goimports", -- Go imports
        "rustfmt", -- Rust
        "sqlfmt", -- SQL
        "taplo", -- TOML
        "xmlformatter", -- XML
        "shfmt", -- Shell

        -- Linters
        "eslint_d", -- JS/TS linting
        "golangci-lint", -- Go
        "shellcheck", -- Shell
      },
    })
  end,
}
