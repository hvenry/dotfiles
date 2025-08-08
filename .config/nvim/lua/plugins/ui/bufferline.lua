return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(_, _, diagnostics_dict, _)
        if diagnostics_dict.error then
          return "  " .. diagnostics_dict.error
        elseif diagnostics_dict.warning then
          return "  " .. diagnostics_dict.warning
        elseif diagnostics_dict.info then
          return "  " .. diagnostics_dict.info
        end
        return ""
      end,
      show_buffer_close_icons = false,
      show_close_icon = false,
    },
    -- make sure bufferline doesn't paint a solid bg
    highlights = {
      fill = { bg = "NONE" },
      background = { bg = "NONE" },
      buffer_visible = { bg = "NONE" },
      buffer_selected = { bg = "NONE" },
      close_button = { bg = "NONE" },
      close_button_visible = { bg = "NONE" },
      close_button_selected = { bg = "NONE" },
      tab = { bg = "NONE" },
      tab_selected = { bg = "NONE" },
      tab_close = { bg = "NONE" },
      indicator_visible = { bg = "NONE" },
      indicator_selected = { bg = "NONE" },
      separator = { bg = "NONE" },
      separator_visible = { bg = "NONE" },
      separator_selected = { bg = "NONE" },
    },
  },
}
