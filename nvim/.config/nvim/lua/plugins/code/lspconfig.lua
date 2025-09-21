return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- diagnostic text configuration
    vim.diagnostic.config({
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.HINT] = "",
          [vim.diagnostic.severity.INFO] = "",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
        end

        map("gr", "<cmd>Telescope lsp_references<CR>", "References")
        map("gd", "<cmd>Telescope lsp_definitions<CR>", "Definitions")
        map("gi", "<cmd>Telescope lsp_implementations<CR>", "Implementations")
        map("gt", "<cmd>Telescope lsp_type_definitions<CR>", "Type definitions")

        map("gb", "<C-o>", "Go Back")
        map("<leader>gf", "<C-i>", "Go Forward")

        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>d", vim.diagnostic.open_float, "Line Diagnostics")
        map("K", vim.lsp.buf.hover, "Hover Doc")
        map("<leader>rs", ":LspRestart<CR>", "Restart LSP")
      end,
    })
  end,
}
