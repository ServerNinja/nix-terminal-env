-- diffview.nvim plugin
--
-- A diff viewer and merge tool for nvim
-- Link: https://github.com/sindrets/diffview.nvim
--
-- Notes: keymaps live in lua/keymaps.lua under the <leader>g prefix. Listing
-- the commands here lets lazy.nvim defer loading until one is used.
return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewFocusFiles',
    'DiffviewToggleFiles',
    'DiffviewRefresh',
    'DiffviewLog',
  },
  config = function()
    require('diffview').setup()
  end
}
