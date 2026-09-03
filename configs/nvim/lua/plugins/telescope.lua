-- telescope.nvim plugin
--
-- For searching for files in the project
-- Link: https://github.com/nvim-telescope/telescope.nvim
--
-- Notes: keymaps live in lua/keymaps.lua (<C-p> -> find_files).
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = 'Telescope',
  opts = {},
}
