return {
  "projekt0n/github-nvim-theme",
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

    -- configure github-nvim-theme
    require("github-theme").setup({
      options = {
        transparent = true, -- enable transparency
      },
      groups = {
        all = {
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          CursorLine = { bg = "NONE" },
          CursorColumn = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          TabLine = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },
          TabLineSel = { bg = "NONE" },
        },
      },
    })

    -- set colorscheme
    vim.cmd.colorscheme("github_dark_default")

    -- make bufferline transparent after applying colorscheme
    make_bufferline_transparent()

    -- reapply transparency whenever colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = make_bufferline_transparent,
    })
  end,
}
