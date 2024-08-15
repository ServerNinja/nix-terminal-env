-- rustaceanvim plugin
--
-- Rust development environment for Neovim.
-- Link: https://github.com/mrcjkb/rustaceanvim
--
-- Notes: Not entirely setup and working properly. Also need to make sure the keymaps don't show up when using the nvim-tree buffer
return {
  'mrcjkb/rustaceanvim',
  require = { 'mfussenegger/nvim-dap'},
  version = '^5', -- Recommended
  lazy = false, -- This plugin is already lazy

}
