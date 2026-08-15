return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>F",
      function()
        -- manual trigger; keep fallback if you like
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    -- 1) Define your formatters
    formatters_by_ft = {
      -- prettier
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },

      lua = { "stylua" },
      python = { "ruff_fix", "ruff_format" },
      go = { "gofumpt", "goimports" },
      rust = { "rustfmt" },
      sql = { "sqlfmt" },
      toml = { "taplo" },
      xml = { "xmlformat" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
    },

    default_format_opts = {
      lsp_format = "fallback",
    },

    format_on_save = {
      timeout_ms = 500,
      lsp_format = "never",
    },

    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
}
