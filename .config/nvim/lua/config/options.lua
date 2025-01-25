vim.opt.relativenumber = true

-- Indent current line or selected lines with Tab in Normal and Visual modes
vim.keymap.set("n", "<Tab>", ">>_", { noremap = true, silent = true })
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true })

-- Outdent current line or selected lines with Shift + Tab in Normal and Visual modes
vim.keymap.set("n", "<S-Tab>", "<<_", { noremap = true, silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- File location
vim.opt.winbar = "%=%m %f"
