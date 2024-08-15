-- nvim-autopairs plugin
-- 
-- Shows pairs of brackets, quotes, etc. and automatically inserts the closing pair when you type the opening pair.``
-- Link: https://github.com/windwp/nvim-autopairs
return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
}
