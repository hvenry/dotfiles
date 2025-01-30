-- map leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

-- KEYMAPS: (vim mode, keymap, what it does, description)

-- this lets use get out of insert mode by pressing jk
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk"})
-- this removes search highlights by pressing <leader>nh
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- splitting window
-- TODO: lock in
keymap.set("n", "<leader>|", "<C-w>v", { desc = "Split window horizontally" })
keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split window vertically" })
keymap.set("n", "<leader>=", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>x", "<cmd>close<CR>", { desc = "Close current split"})

-- tabs (buffers)
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "H", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "L", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
