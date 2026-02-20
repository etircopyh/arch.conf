local fn    = vim.fn
local utils = require('utils')

require 'os'

vim.cmd [[colorscheme gruvbox-baby]]

vim.g.mapleader = ','

local global_vim_options = {}

local vim_options = {
    background = 'dark',

    ttyfast = true,

    wrap     = false,
    undofile = true,

    showmode = false,

    completeopt = { 'menu', 'menuone', 'noselect' },

    directory = os.getenv('XDG_STATE_HOME') .. '/nvim/swap//',
    backupdir = os.getenv('XDG_STATE_HOME') .. '/nvim/swap//',
    undodir   = os.getenv('XDG_STATE_HOME') .. '/nvim/undo//',
    viewdir   = os.getenv('XDG_STATE_HOME') .. '/nvim/view//',

    list      = true,
    showbreak = '↪ ',
    listchars = {
        tab      = '▸ ',
        nbsp     = '⍽',
        extends  = '⟩',
        precedes = '⟨',
        trail    = '⋅',
        eol      = '↲',
    },

    splitbelow = true,
    splitright = true,

    foldexpr = 'nvim_treesitter#foldexpr()',

    title       = true,
    titlestring = '%<%F%= - nvim',

    pumheight = 10,

    termguicolors = true,

    -- Search
    ignorecase = true,
    smartcase  = true,
    incsearch  = true,
    showmatch  = true,
    hlsearch   = true,

    lazyredraw = true,

    synmaxcol = 240,

    joinspaces = false,

    signcolumn = 'number',

    mouse      = 'a',
    autoread   = true,
    hidden     = true,
    scrolloff  = 3,
    sidescroll = 3,

    ruler       = true,
    rulerformat = '%l,%v',

    errorbells = false,
    visualbell = false,

    wildmenu   = true,
    wildmode   = 'list:full,full',
    wildignore = { '*.o', '*.obj', '*~', '*.pyc', '*.so', '*.swp', 'tmp/', '*.pdf', '*.jpg', '*.dmg', '*.zip', '*.png', '*.gif', '*DS_Store*' },

    formatoptions = 'croqn2l1',

    number         = true,
    relativenumber = false,

    cursorline = true,

    cmdheight = 2,
    history   = 10000,

    spell = false,
    spelllang = 'en',

    updatetime = 300,
    -- Indentation
    expandtab   = true,
    smarttab    = true,
    autoindent  = true,
    smartindent = true,
    copyindent  = true,
    shiftround  = true,
    tabstop     = 4,
    softtabstop = 4,
    shiftwidth  = 4,

    diffopt = vim.opt.diffopt + 'vertical',

    shortmess = vim.opt.shortmess + 'c'
}

for k, v in pairs(global_vim_options) do
    vim.g[k] = v
end

for k, v in pairs(vim_options) do
    vim.opt[k] = v
end

if fn.has('unix') then
    if not os.getenv('WAYLAND_DISPLAY') or (os.getenv('XDG_SESSION_TYPE') == 'wayland') then
        if os.getenv('XDG_CURRENT_DESKTOP') == 'sway' then
            vim.cmd [[autocmd InsertLeave,BufEnter * silent call system('swaymsg input type:keyboard xkb_switch_layout 0')]]
        end
    elseif os.getenv('XDG_CURRENT_DESKTOP') == 'KDE' then
        vim.cmd [[autocmd InsertLeave,BufEnter * silent call system('qdbus org.kde.keyboard /Layouts setLayout us')]]
    elseif not os.getenv('DISPLAY') and os.getenv('XDG_SESSION_TYPE') == 'x11' then
        vim.cmd [[autocmd InsertLeave,BufEnter * silent call system('something')]]
    end
end

local disabled_built_ins = {
    'gzip',
    'zip',
    'zipPlugin',
    'tar',
    'tarPlugin',
    'getscript',
    'getscriptPlugin',
    'vimball',
    'vimballPlugin',
    '2html_plugin',
    'logipat',
    'rrhelper',
    'spellfile_plugin',
    'matchit'
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g['loaded_' .. plugin] = 1
end




require('plugins')
require('lsp')

require('treesitter')

require('keymaps')
