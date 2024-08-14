return {
  "nvim-zh/colorful-winsep.nvim",
  config = true,
  event = { "WinLeave" },

  config = function()
    require("colorful-winsep").setup({
      -- Setup overrides here
    }) 
  end,
}
