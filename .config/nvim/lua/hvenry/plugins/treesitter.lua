return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")
    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (using nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- specific language parsers are installed
      ensure_installed = {
        "json",
        "java",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "prisma",
        "python",
        "markdown",
        "markdown_inline",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "go",
        "gitignore",
        "query",
        "vimdoc",
        "c",
        "cpp",
        "html",
        "rust",
        "scala",
        "sql",
        "vue",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
