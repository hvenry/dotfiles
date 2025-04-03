return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
          hide_by_name = {
            ".git",
            "node_modules",
          },
          never_show = {
            ".DS_Store",
            "Thumbs.db",
          },
        },
      },
      window = {
        position = "right",
        width = 30,
        mappings = {
          ["<CR>"] = "open",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["/"] = { "fuzzy_finder", config = { title = "Filter" } },
          ["f"] = "filter_on_submit",
          ["s"] = "open_vsplit",
          ["S"] = "open_split",
        },
        preserve_window_proportions = true,
      },
      buffers = {
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function(arg)
            vim.opt_local.signcolumn = "auto"
            vim.opt_local.winbar = "%#Directory# [ File Explorer ] %*"
          end,
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
        },
        git_status = {
          symbols = {
            added = "✚",
            modified = "",
            deleted = "✖",
            renamed = "➜",
            untracked = "★",
            ignored = "◌",
            unstaged = "✗",
            staged = "✓",
            conflict = "",
          },
        },
      },
    })

    -- open with space e
    vim.api.nvim_set_keymap(
      "n",
      "<leader>e",
      ":Neotree toggle<CR>",
      { noremap = true, silent = true, desc = "Explorer NeoTree toggle" }
    )
  end,
}
