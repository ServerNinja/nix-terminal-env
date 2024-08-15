-- mini.icons plugin
--
-- An icons provider for nvim - a prerequisite plugins
-- Link: https://github.com/echasnovski/mini.icons
return { 
  'echasnovski/mini.icons',
  version = false,
  config = function()
    require('mini.icons').setup()
  end,
}
