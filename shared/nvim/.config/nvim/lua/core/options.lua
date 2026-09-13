-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- relative line number and absolute line number
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- highlight current cursor line
opt.cursorline = false

-- appearence
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- keep undo history across sessions (in ~/.local/state/nvim/undo)
opt.undofile = true

-- keep some context visible around the cursor
opt.scrolloff = 8

-- faster CursorHold: gitsigns blame, LSP highlights
opt.updatetime = 250

-- ask to save instead of failing on :q with unsaved changes
opt.confirm = true

-- use system clipboard
opt.clipboard:append("unnamedplus")

-- window splitting
opt.splitright = true
opt.splitbelow = true

-- Set the command line background color
-- vim.api.nvim_set_hl(0, "MsgArea", { fg = "#ffffff" })
