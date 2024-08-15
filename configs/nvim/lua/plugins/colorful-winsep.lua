-- colorful-winsep.nvim plugin
--
-- Shows a different color window separator for active window
-- Link: https://github.com/nvim-zh/colorful-winsep.nvim
return {
  "nvim-zh/colorful-winsep.nvim",
  config = true,
  event = { "WinLeave" },

  config = function()
    require("colorful-winsep").setup()
  end,
}
