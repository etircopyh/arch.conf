--require('mapx').setup { global = true }

local map = vim.keymap.set


-- EZ cmdline entrance
--nnoremap(';', ':')
map('n', ';', ':')

-- Undo-friendly <C-u> <C-w>
map('i', '<C-u>', '<C-g>u<C-u>')
map('i', '<C-w>', '<C-g>u<C-w>')

-- Normal mode newline
map('n', '<leader>o', 'm`o<Esc>``')

-- Quick mouse yanking
map('v', '<LeftRelease>', '"*ygv')
--vnoremap('<LeftRelease>', '"*ygv')

-- Thanks to Steve Losh for this liberating tip
-- See http://stevelosh.com/blog/2010/09/coming-home-to-vim
map({ 'n', 'v' }, '/', '/\\v')
--vnoremap('/', '/\\v')

map({}, 'n', 'nzz')
map({}, 'N', 'Nzz')
--noremap('n', 'nzz')
--noremap('N', 'Nzz')

map({'x', 'n'}, 'ga', '<Plug>(EasyAlign)')
--xnoremap('ga', '<Plug>(EasyAlign)')
--nnoremap('ga', '<Plug>(EasyAlign)')


map('n', '<leader>w', ':update<CR>')
--nnoremap('<leader>w', ':update<CR>')

map('n', '<leader>q', ':quit<CR>')
--nnoremap('<leader>q', ':quit<CR>')

map('n', '<leader>t', ':tabnew<CR>')
--nnoremap('<leader>t', ':tabnew<CR>')


-- Fast scrolling through
map('n', '<Space>j', '10j<Space>')
map('n', '<Space>k', '10k<Space>')
map('n', '<Space><Space>', '<Nop>')

-- System clipboard
map({'n', 'v'}, '<leader>y', '"+y')
--vnoremap('<leader>y', '"+y')
--nnoremap('<leader>y', '"+y')
map('n', '<leader>Y', '"+yg_')
--nnoremap('<leader>Y', '"+yg_')
map('n', '<leader>d', '"+d')
--nnoremap('<leader>d', '"+d')
map({'n', 'v'}, '<leader>p', '"+p')
--vnoremap('<leader>p', '"+p')
--nnoremap('<leader>p', '"+p')
map('n', '<leader>yy', '"+yy')
--nnoremap('<leader>yy', '"+yy')

-- Paste from clipboard
map({'n', 'v'}, '<leader>P', '"+P')
--nnoremap('<leader>P', '"+P')
--vnoremap('<leader>P', '"+P')
map({'n', 'v'}, '<leader>p', '"+p')
--nnoremap('<leader>p', '"+p')
--vnoremap('<leader>p', '"+p')

map('n', 'Q', 'gq')

map('i', '<F10>', '<C-0>cit')

map({} ,',e', '^wy$:r!"')

-- ALE
map('n', '<C-k>', '<Plug>(ale_previous_wrap)')
map('n', '<C-j>', '<Plug>(ale_next_wrap)')

map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { silent = true })
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<Cr>', { silent = true })

map('i', '<C-c>', '<ESC>')

-- Tab-completion
map('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { silent = true, expr = true })
map('i', '<S-Tab>', function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { silent = true, expr = true })

map('n', '<leader>n', ':NvimTreeFindFile<CR>')
map('n', '<C-n>', ':NvimTreeToggle<CR>')


map('n', '<space>a', function() return vim.lsp.buf.code_action() end)
map('n', '<space>h', function() return vim.lsp.buf.hover() end)
map('n', '<space>d', function() return vim.lsp.buf.definition() end)
map('n', '<space>e', function() return vim.lsp.buf.declaration() end)
map('n', '<space>i', function() return vim.lsp.buf.implementation() end)
map('n', '<space>t', function() return vim.lsp.buf.type_definition() end)

-- Diagnostic keymaps
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })

-- Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', 'v:count == 0 ? "gk" : "k"', { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', 'v:count == 0 ? "gj" : "j"', { noremap = true, expr = true, silent = true })

--Map blankline
vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_show_trailing_blankline_indent = false


--[[ vim.g.skim_action = {
  'ctrl-t': 'tab split',
  'ctrl-x': 'split',
  'ctrl-v': 'vsplit'
} ]]


vim.cmd [[ autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=800, on_visual = false } ]]
