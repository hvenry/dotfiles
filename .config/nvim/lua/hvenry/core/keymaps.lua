-- map leader key to space
vim.g.mapleader = " "
local keymap = vim.keymap

-- GENERAL KEYBINDINGS
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode ith jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- WINDOW SPLITTING
keymap.set("n", "<leader>|", "<C-w>v", { desc = "Split window horizontally" })
keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split window vertically" })
keymap.set("n", "<leader>=", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>x", "<cmd>close<CR>", { desc = "Close current split" })

-- BUFFER NAVIGATION
keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { desc = "Go to previous buffer", silent = true })
keymap.set("n", "L", ":BufferLineCycleNext<CR>", { desc = "Go to next buffer", silent = true })
keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Go to previous buffer (alt)", silent = true })
keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Go to next buffer (alt)", silent = true })

-- Smart buffer deletion that preserving layout
keymap.set("n", "<leader>bd", function()
  -- get current buffer number
  local current_buf = vim.api.nvim_get_current_buf()
  -- check if it's a Neo-tree buffer
  local filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")

  if filetype == "neo-tree" then
    -- if it's a Neo-tree buffer, just close it
    vim.cmd("wincmd c")
  else
    -- for regular buffers, use bufdelete and handle layout preservation
    vim.cmd("Bdelete!")
  end
end, { desc = "Delete current buffer", silent = true })
