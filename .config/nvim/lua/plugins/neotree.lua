return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = true,
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        visible = true,
      },
    },
  },
  keys = {
    {
      "<Space>e",
      function()
        require("neo-tree.command").execute({
          toggle = true,
          dir = vim.fn.getcwd(),
        })
      end,
      desc = "Open NeoTree in current directory",
    },
  },
}
