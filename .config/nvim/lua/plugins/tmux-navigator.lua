return {
  "christoomey/vim-tmux-navigator",
  config = function()
    -- Disable default mappings provided by vim-tmux-navigator
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
