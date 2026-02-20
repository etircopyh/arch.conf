local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = false }


vim.g.mapleader = ','

-- EZ cmdline entrance
map('n', ';', ':', { noremap = true })

-- Quick mouse yanking
map('v', '<LeftRelease>', '"*ygv', default_opts)

-- Thanks to Steve Losh for this liberating tip
-- See http://stevelosh.com/blog/2010/09/coming-home-to-vim
map('n', '/', '/\\v', default_opts)
map('v', '/', '/\\v', default_opts)



-- System clipboard
map('v', '<leader>y', '"+y', default_opts)
map('n', '<leader>Y', '"+yg_', default_opts)
map('n', '<leader>y', '"+y', default_opts)
map('n', '<leader>d', '"+d', default_opts)
map('v', '<leader>p', '"+p', default_opts)
map('n', '<leader>p', '"+p', default_opts)
map('n', '<leader>yy', '"+yy', default_opts)

-- Paste from clipboard
map('n', '<leader>p', '"+p', default_opts)
map('n', '<leader>P', '"+P', default_opts)
map('v', '<leader>p', '"+p', default_opts)
map('v', '<leader>P', '"+P', default_opts)

-- ALE
map('n', '<C-k>', '<Plug>(ale_previous_wrap)', default_opts)
map('n', '<C-j>', '<Plug>(ale_next_wrap)', default_opts)

map('n', 'K', '<cmd>:call <SID>show_documentation()<CR>', default_opts)

map('i', '<C-c>', '<ESC>', default_opts)

-- Tab-completion
--[[ map('i', '<Tab>', 'pumvisible() ? "<C-n>" : "<Tab>"'), default_opts)
map('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"'), default_opts) ]]

--[[ vim.g.skim_action = {
  'ctrl-t': 'tab split',
  'ctrl-x': 'split',
  'ctrl-v': 'vsplit'
} ]]
