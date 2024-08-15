-- auto-dark-mode.nvim plugin
--
-- Automatically switch between light and dark mode based on OS Settings
-- Link: https://github.com/f-person/auto-dark-mode.nvim
return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd("colorscheme catppuccin")
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd("colorscheme flexoki-light")
    end,
  },
}
