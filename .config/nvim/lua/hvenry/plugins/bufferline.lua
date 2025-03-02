return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",

  opts = {
    options = {
      mode = "buffers",
      separator_style = "thick",
      always_show_bufferline = true,

      -- Enable LSP diagnostics
      diagnostics = "nvim_lsp",

      -- Custom indicator for diagnostics
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,

      -- Customize buffer name display with diagnostics
      diagnostics_update_in_insert = false,
      show_buffer_close_icons = true,
      show_close_icon = false,

      -- Customize left and right offsets
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true,
        },
      },
    },
  },
}
