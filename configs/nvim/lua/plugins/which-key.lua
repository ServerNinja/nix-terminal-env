-- which-key.nvim
--
-- A plugin to assist with helping you remember keybindings
-- Link: https://github.com/folke/which-key.nvim
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Sort everything alphanumerically. The default is
    -- { "local", "order", "group", "alphanum", "mod" }; both "group" (forces
    -- groups to the end) and "local" (hoists buffer-local maps like <leader>o
    -- for Oil) break key order, so they are dropped. "order" is kept because
    -- which-key plugins (marks, registers) rely on it for meaningful order.
    sort = { "order", "alphanum", "mod" },
    win = {
--      no_overlap = true,
      border = "single",
      padding = { 1, 2 },
      title = true,
      title_pos = "center",
      zindex = 1000,
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    -- As an example, we will create the following mappings:
    --  * <leader>ff find files
    --  * <leader>fr show recent files
    --  * <leader>fb Foobar
    -- we'll document:
    --  * <leader>fn new file
    --  * <leader>fe edit file
    -- -- and hide <leader>1
   
    wk.add({
    -- group renames
      { "<leader>c", group = "Markdown Preview", icon = { icon = "", color = "orange" } },
      { "<leader>g", group = "Git Diff (Diffview)", icon = { icon = "", color = "red" } },
      { "<leader>f", group = "Find (Telescope)", icon = { icon = "", color = "yellow" } },
      { "<leader>h", group = "Git Hunks (Gitsigns)", icon = { icon = "", color = "orange" } },
      { "<leader>l", group = "Lazy"},
      { "<leader>m", group = "Obsidian Notes", icon = { icon = "", color = "purple" } },
      { "<leader>n", group = "Window Navigation", icon = { icon = "", color = "azure" } },
      { "<leader>s", group = "Split", icon = { icon = "", color = "purple" } },
      { "<leader>t", group = "Tab Management", icon = { icon = "", color = "green" } },
      { "<leader>w", group = "Window Management", icon = { icon = "", color = "azure" } },
    }, { prefix = "<leader>" })
    wk.setup(opts)
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
