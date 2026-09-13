-- nvim-treesitter `main` branch: no modules, no ensure_installed, no lazy-loading.
-- Needs the tree-sitter CLI and a C compiler to build parsers.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = { "windwp/nvim-ts-autotag" },
  config = function()
    local ts = require("nvim-treesitter")

    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
    local ensure_installed = {
      "bash",
      "lua",
      "python",
      "javascript",
      "typescript",
      "html",
      "prisma",
      "markdown",
      "markdown_inline",
    }

    local installed = ts.get_installed()
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure_installed)
    if #missing > 0 then
      ts.install(missing)
    end

    -- `main` does not start highlighting for us; pcall since most filetypes
    -- have no parser.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    -- Keep this explicit: autotag's fallback path requires `nvim-treesitter.configs`,
    -- which `main` removed, and crashes instead of bailing out.
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    })
  end,
}
