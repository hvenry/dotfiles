return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        position = "right", -- "float"
        width = 30,
        mappings = {
          ["<CR>"] = "open",
        },
        preserve_window_proportions = true, -- prevents window size changes
      },
      buffers = {
        follow_current_file = { enabled = true }, -- auto-focus buffer you navigate to
        group_empty_dirs = true,
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.opt_local.signcolumn = "auto"
          end,
        },
      },
    })

    -- Toggle Neo-tree
    vim.api.nvim_set_keymap("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true })

    -- Auto-open Neo-tree when starting Neovim with a directory argument
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        -- Check if a directory was passed as an argument
        local directory = vim.fn.isdirectory(data.file) == 1

        if directory then
          -- Change to the directory
          vim.cmd.cd(data.file)

          -- Open Neo-tree automatically
          vim.cmd("Neotree show")

          -- Clear the unnamed buffer
          vim.cmd("bd " .. data.buf)
        end
      end,
    })
  end,
}
