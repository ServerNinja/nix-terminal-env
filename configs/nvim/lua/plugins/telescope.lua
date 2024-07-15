return { 
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim'},

  config = function()
    local telescope = require("telescope.builtin")
    vim.keymap.set('n', '<C-p>', telescope.find_files, {})
  end
}
