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
keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete current buffer", silent = true })
