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

-- WINDOW RESIZING (like tmux)
local function enter_resize_mode()
  print("Resize mode: h/j/k/l to resize, any other key to exit")
  while true do
    local key = vim.fn.getchar()
    local char = type(key) == "number" and vim.fn.nr2char(key) or key

    if char == "h" then
      vim.cmd("vertical resize -2")
      vim.cmd("redraw")
    elseif char == "j" then
      vim.cmd("resize -2")
      vim.cmd("redraw")
    elseif char == "k" then
      vim.cmd("resize +2")
      vim.cmd("redraw")
    elseif char == "l" then
      vim.cmd("vertical resize +2")
      vim.cmd("redraw")
    else
      print("Exited resize mode")
      break
    end
  end
end

keymap.set("n", "<leader>r", enter_resize_mode, { desc = "Enter resize mode" })

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
    -- for regular buffers, use bufdelete
    vim.cmd("Bdelete!")
  end
end, { desc = "Delete current buffer", silent = true })

-- Indentation
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent current line(s)", noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Outdent current line(s)", noremap = true, silent = true })

-- Indent and re-select in visual mode
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection", noremap = true, silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Outdent selection", noremap = true, silent = true })
