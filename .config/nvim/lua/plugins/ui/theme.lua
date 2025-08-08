return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    vim.opt.termguicolors = true

    -- helper to (re)apply transparent backgrounds to Bufferline/tabline
    local function make_bufferline_transparent()
      local groups = {
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineBuffer",
        "BufferLineBufferVisible",
        "BufferLineBufferSelected",
        "BufferLineSeparator",
        "BufferLineSeparatorVisible",
        "BufferLineSeparatorSelected",
        "BufferLineIndicatorSelected",
        "BufferLineCloseButton",
        "BufferLineCloseButtonVisible",
        "BufferLineCloseButtonSelected",
        "BufferLineTab",
        "BufferLineTabSelected",
        "BufferLineTabClose",
      }
      for _, g in ipairs(groups) do
        pcall(vim.api.nvim_set_hl, 0, g, { bg = "NONE" })
      end
    end

    require("tokyonight").setup({
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent" },
      -- Make the built-in tabline transparent too
      on_highlights = function(hl)
        hl.TabLine = { bg = "NONE" }
        hl.TabLineFill = { bg = "NONE" }
        hl.TabLineSel = { bg = "NONE" }
      end,
    })

    -- set colorscheme, then immediately fix bufferline highlights
    vim.cmd.colorscheme("tokyonight")
    make_bufferline_transparent()

    -- ensure it stays transparent if the colorscheme changes later
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = make_bufferline_transparent,
    })
  end,
}
