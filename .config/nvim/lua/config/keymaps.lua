-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Telescope: sx resumes last telescope picker opened previously
vim.keymap.set(
  "n",
  "<leader>sx",
  require("telescope.builtin").resume,
  { noremap = true, silent = true, desc = "Resume" }
)

-- Use Telescope's `oldfiles` picker for recently opened files
vim.keymap.set(
  "n",
  "<leader>fh",
  "<cmd>Telescope frecency<CR>",
  { noremap = true, silent = true, desc = "Recent Files (Frecency)" }
)

-- Set up keymap for file browser using Telescope
vim.keymap.set("n", "<leader>sB", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.expand("%:p:h"),
  })
end, { noremap = true, silent = true, desc = "Browse Files" })

-- Tmux Navigator Keybindings
vim.keymap.set(
  "n",
  "<C-h>",
  "<cmd> TmuxNavigateLeft<CR>",
  { noremap = true, silent = true, desc = "Window Left" }
)
vim.keymap.set(
  "n",
  "<C-j>",
  "<cmd> TmuxNavigateDown<CR>",
  { noremap = true, silent = true, desc = "Window Down" }
)
vim.keymap.set(
  "n",
  "<C-k>",
  "<cmd> TmuxNavigateUp<CR>",
  { noremap = true, silent = true, desc = "Window Up" }
)
vim.keymap.set(
  "n",
  "<C-l>",
  "<cmd> TmuxNavigateRight<CR>",
  { noremap = true, silent = true, desc = "Window Right" }
)
