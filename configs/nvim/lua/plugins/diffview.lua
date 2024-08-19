-- diffview.nvim plugin
--
-- A diff viewer and merge tool for nvim
-- Link: https://github.com/sindrets/diffview.nvim
return {
  'sindrets/diffview.nvim',
  config = function()
    require('diffview').setup()
  end
}
