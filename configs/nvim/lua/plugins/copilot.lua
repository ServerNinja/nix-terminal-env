-- copilot.lua plugin
--
-- Realtime Copilot coding for Neovim
-- Link: https://github.com/zbirenbaum/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  build = ":Copilot auth",
  opts = {
    -- for lua-cmp
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = true,
      debounce = 75,
      keymap = {
        accept = "<M-l>",
        accept_word = "<M-j>",
        accept_line = "<M-k>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<M-h>",
      },
    },
  },
}
