-- colorful-winsep.nvim plugin
--
-- Shows a different color window separator for active window
-- Link: https://github.com/nvim-zh/colorful-winsep.nvim
--
-- Notes: pinned to `main`. The `alpha` branch this was originally installed
-- from no longer exists upstream, which made `:Lazy update` fail on it.
return {
  "nvim-zh/colorful-winsep.nvim",
  branch = "main",
  event = { "WinLeave" },
  config = function()
    require("colorful-winsep").setup()
  end,
}
