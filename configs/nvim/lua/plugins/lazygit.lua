-- LazyGit plugin
--
-- Calls the LazyGit command to open a git interface in a floating window
-- Link: https://github.com/kdheepak/lazygit.nvim
return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
