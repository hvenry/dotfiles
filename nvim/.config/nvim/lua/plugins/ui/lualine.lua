return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    -- Mode highlight colors
    local colors = {
      blue = "#65D1FF", -- normal
      green = "#3effa2", -- insert
      violet = "#FF61EF", -- visual
      yellow = "#FFDA7B", -- command
      red = "#FF4A4A", -- replace
      fg = "#FFFFFF", -- white text
      bg = "#000000", -- black background
      inactive_bg = "#1A1A1A", -- slightly lighter for inactive
    }

    -- Define lualine theme
    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = "#777777", gui = "bold" },
        b = { bg = colors.inactive_bg, fg = "#777777" },
        c = { bg = colors.inactive_bg, fg = "#777777" },
      },
    }

    lualine.setup({
      options = {
        theme = my_lualine_theme,
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "alpha", "dashboard", "starter" } },
        icons_enabled = true,
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          { "diagnostics", sources = { "nvim_diagnostic" } },
        },
        lualine_c = {
          {
            "filename",
            path = 1,
            file_status = true,
            newfile_status = true,
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
              newfile = " [New]",
            },
          },
        },

        -- right side
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = colors.yellow },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 2 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },

      extensions = { "quickfix", "man", "fugitive", "nvim-tree", "lazy" },
    })
  end,
}
