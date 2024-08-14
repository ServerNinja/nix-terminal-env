-- Enable absolute line numbers
vim.wo.number = true

-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {}

-- Load options
require("vim-options")
require("keymaps")

-- LazyVim configuration
-- Load plugins from lua/plugins.lua
-- Docs: https://lazy.folke.io/
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Lazy ui config
  ui = {
    border = "double",
    size = {
      width = 0.8,
      height = 0.8,
    },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
