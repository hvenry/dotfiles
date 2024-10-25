-- Bootstrap Lazy.nvim ^u^

-- Ensure lazy.nvim is installed in 'data' directory
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- If not found, clone from GitHub using vim.fn.system
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  -- Error handling if cloning fails:
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Ensure lazy.nvim is included in Neovim's runtime path
vim.opt.rtp:prepend(lazypath)

-- Load and configure Neovim
require("lazy").setup({
  -- Plugin Specifications
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "plugins" },
  },
  --  Default Plugin Settings
  defaults = {
    lazy = false,
    version = false,
  },
  -- Performance optimizations
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "mini-animate",
      },
    },
  },
  -- Check Plugins for updates
  checker = { enabled = true, notify = false },
})
