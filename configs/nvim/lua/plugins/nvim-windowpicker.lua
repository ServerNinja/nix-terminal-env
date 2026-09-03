-- nvim-window-picker plugin
--
-- Prompts for a target window with a letter hint. Used by nvim-tree when
-- opening a file into an existing split.
-- Link: https://github.com/s1n7ax/nvim-window-picker
--
-- Notes: setup() is called here only. nvim-tree consumes this plugin via
-- actions.open_file.window_picker.enable and must not call setup() again.
return {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    opts = {
        autoselect_one = true,
        include_current_win = false,
        filter_rules = {
            -- filter using buffer options
            bo = {
                filetype = { "NvimTree", "neo-tree", "notify" },
                buftype = { "terminal", "quickfix" },
            },
        },
        other_win_hl_color = "#e35e4f",
    },
}
