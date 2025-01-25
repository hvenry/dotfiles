-- Tmux Navigator Keybindings
-- left
vim.keymap.set(
  "n",
  "<C-h>",
  "<cmd> TmuxNavigateLeft<CR>",
  { noremap = true, silent = true, desc = "Window Left" }
)
-- down
vim.keymap.set(
  "n",
  "<C-j>",
  "<cmd> TmuxNavigateDown<CR>",
  { noremap = true, silent = true, desc = "Window Down" }
)
-- up
vim.keymap.set(
  "n",
  "<C-k>",
  "<cmd> TmuxNavigateUp<CR>",
  { noremap = true, silent = true, desc = "Window Up" }
)
-- right
vim.keymap.set(
  "n",
  "<C-l>",
  "<cmd> TmuxNavigateRight<CR>",
  { noremap = true, silent = true, desc = "Window Right" }
)

-- Indent selected lines with Tab in Normal and Visual modes
vim.keymap.set("n", "<Tab>", ">>_", { noremap = true, silent = true })
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true })

-- Outdent selected lines with Shift + Tab in Normal and Visual modes
vim.keymap.set("n", "<S-Tab>", "<<_", { noremap = true, silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true })
