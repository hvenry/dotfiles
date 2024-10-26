-- Configuration to completions to not accept unless dropdown is specified
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    -- Snippet engine
    "L3MON4D3/LuaSnip",
    -- Snippet integration for nvim-cmp
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    -- setup completeopt as Neovim's built-in competion
    vim.o.completeopt = "menuone,noselect,preview"

    -- load in required modules
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      -- Prevent automatic selection of completion items
      preselect = cmp.PreselectMode.None,
      -- Snippet configuration (snippet.expand defines how expand using LuaSnip works)
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- Key mappings
      mapping = {
        -- Confirm only if a selection is made
        -- <Enter> confirm suggestion only if it is explicitly selected
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        -- Add arrow key navigation
        ["<Down>"] = cmp.mapping.select_next_item({
          behavior = cmp.SelectBehavior.Select,
        }),
        ["<Up>"] = cmp.mapping.select_prev_item({
          behavior = cmp.SelectBehavior.Select,
        }),
      },

      -- Completion sources
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      },
    })
  end,
}
