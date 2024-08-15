-- telescope.nvim plugin
--
-- For searching for files in the project
-- Link: https://github.com/nvim-telescope/telescope.nvim
return { 
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim'},

  config = function()
    local telescope = require("telescope.builtin")
  end
}
