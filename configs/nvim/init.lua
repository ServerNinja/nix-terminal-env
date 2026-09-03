-- Enable absolute line numbers
vim.wo.number = true

-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

-- Neovim 0.12's built-in Markdown ftplugin starts Tree-sitter automatically.
-- Keep Tree-sitter enabled elsewhere, but use vim-markdown's legacy syntax for
-- Markdown until the upstream highlighter crash is fixed.
local treesitter_start = vim.treesitter.start
vim.treesitter.start = function(buf, lang)
  local bufnr = buf or 0
  if lang == "markdown" or vim.bo[bufnr].filetype == "markdown" then
    return
  end
  return treesitter_start(buf, lang)
end

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
    -- notify = true prints every pending plugin on startup and blocks on a
    -- hit-enter prompt. The count is shown in the lualine winbar instead
    -- (see lua/plugins/lualine.lua); run :Lazy check or :Lazy for details.
    notify = false,
    frequency = 86400, -- once a day is plenty for a shared lockfile
  },
  change_detection = {
    notify = false,
  },
})
