-- oil.nvim plugin
--
-- A file explorer plugin. Also gives capability to edit file tree in a vim style editor in a floating window.
-- Link: https://github.com/stevearc/oil.nvim
--
-- Notes: I'm currently integrating this with nvim-tree - see the nvim-tree.lua file for details.
return {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  config = function()
    require("oil").setup({
      default_file_explorer = false,
    })
  end
}
