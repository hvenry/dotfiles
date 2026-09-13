-- Floating terminals for external TUIs (lazygit, lazydocker).
-- Both binaries come from the package lists, not from here.
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>gg", desc = "Lazygit" },
    { "<leader>td", desc = "Lazydocker" },
  },
  opts = {
    direction = "float",
    float_opts = { border = "rounded" },
    -- Close the float with <Esc> instead of it going to the TUI.
    shade_terminals = false,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    local function tui(cmd)
      local term = Terminal:new({
        cmd = cmd,
        direction = "float",
        hidden = true,
        -- These tools write to disk behind nvim's back; re-read changed
        -- buffers on exit so the editor does not show stale content.
        on_close = function()
          vim.schedule(function()
            vim.cmd("checktime")
          end)
        end,
      })
      return function()
        if vim.fn.executable(cmd) == 0 then
          vim.notify(cmd .. " is not installed", vim.log.levels.WARN)
          return
        end
        term:toggle()
      end
    end

    vim.keymap.set("n", "<leader>gg", tui("lazygit"), { desc = "Lazygit" })
    vim.keymap.set("n", "<leader>td", tui("lazydocker"), { desc = "Lazydocker" })
  end,
}
