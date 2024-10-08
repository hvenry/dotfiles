-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- new keymap for normal mode, sx resumes last telescope picker opened previously
vim.keymap.set(
  "n",
  "<leader>sx",
  require("telescope.builtin").resume,
  { noremap = true, silent = true, desc = "Resume" }
)

-- Tmux Navigator Keybindings
vim.keymap.set("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { noremap = true, silent = true, desc = "window left" })
vim.keymap.set("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { noremap = true, silent = true, desc = "window down" })
vim.keymap.set("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>", { noremap = true, silent = true, desc = "window up" })
vim.keymap.set("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { noremap = true, silent = true, desc = "window right" })
