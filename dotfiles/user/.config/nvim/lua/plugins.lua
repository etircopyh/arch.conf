local cmd = vim.cmd
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

cmd [[packadd packer.nvim]]

require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        'lewis6991/spellsitter.nvim',
        config = function()
            require('spellsitter').setup()
        end
    }

    use {
        'romgrk/nvim-treesitter-context',
        requires = { 'nvim-treesitter/nvim-treesitter' },
        run = ':TSUpdate',
        config = function()
            require'treesitter-context'.setup{
                enable = true,
                throttle = true,
            }
        end
    }

    use {
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            require('indent_blankline').setup {
                use_treesitter = true,
                show_end_of_line = true,
                buftype_exclude = { "terminal" },
            }
        end
    }

    --[[ use {
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup()
        end
    } ]]

    use {
        'jghauser/mkdir.nvim',
        config = function()
            require('mkdir')
        end
    }

    use {
        'saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('crates').setup()
        end,
    }

    use {
        "vuki656/package-info.nvim",
        event = { "BufRead package.json" },
        requires = "MunifTanjim/nui.nvim",
        config = function()
            require('package-info').setup()
        end,
    }

    use {
        'echasnovski/mini.nvim',
        config = function()
            require('mini.surround').setup()
            require('mini.pairs').setup()
            require('mini.comment').setup()
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('gitsigns').setup { word_diff = true }
        end
    }

    use {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end
    }

    -- Useful stuff
    use {
        'henriquehbr/nvim-startup.lua',
        config = function()
            require('nvim-startup').setup()
        end
    }

    use 'farmergreg/vim-lastplace'

    use {
        'cappyzawa/trim.nvim',
        config = function()
            require('trim').setup {
                disable = { "markdown", "cpp", "vim", "txt", "patch", "c" },
                patterns = {
                    [[%s/\s\+$//e]],
                    [[%s/\($\n\s*\)\+\%$//]],
                },
            }
        end
    }

    use {
        'winston0410/range-highlight.nvim',
        requires = { 'winston0410/cmd-parser.nvim' },
        config = function()
            require('range-highlight').setup()
        end
    }

    use {
        'beauwilliams/focus.nvim',
        cmd = { "FocusSplitNicely", "FocusSplitCycle" },
        module = "focus",
        config = function()
            require("focus").setup { hybridnumber = true }
        end
    }

    use {
        'kyazdani42/nvim-tree.lua',
        requires = { 'kyazdani42/nvim-web-devicons' },
        config = function()
            require('nvim-tree').setup {
                open_on_setup = true,
                auto_close = true,
                system_open = { cmd = "xdg-open" },
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                },
            }
        end
    }

    use {
        'kosayoda/nvim-lightbulb',
        --config = 'vim.cmd[[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]'
    }

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/nvim-cmp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    }

    use {
        'RishabhRD/nvim-lsputils',
        requires = { 'RishabhRD/popfix' }
    }

    use 'onsails/lspkind-nvim'

    use 'hood/popui.nvim'

    --use 'b3nj5m1n/kommentary'

    use {
        'AckslD/nvim-neoclip.lua',
        requires = { 'nvim-telescope/telescope.nvim' },
        config = function()
            require('neoclip').setup{
                history = 10000,
                --enable_persistant_history = true,
            }
        end,
    }

    use 'aonemd/kuroi.vim'

    use 'sainnhe/sonokai'

    --use 'itchyny/lightline.vim'

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup { options = { theme = 'sonokai' } }
        end
    }

    use 'AndrewRadev/splitjoin.vim'

    use {
        'editorconfig/editorconfig-vim',
        event = { "BufRead .editorconfig" },
    }

    use 'lambdalisue/suda.vim'
    if (vim.o.diff == false) then
        vim.g.suda_smart_edit = 1
    end

    use 'junegunn/vim-easy-align'

    use 'jackguo380/vim-lsp-cxx-highlight'
    vim.g = {
        cpp_class_scope_highlight = 1,
        cpp_member_variable_highlight = 1,
        cpp_class_decl_highlight = 1,
        lsp_cxx_hl_use_text_props = 1,
    }

    use {
        'dense-analysis/ale',
        --requires = { 'maximbaz/lightline-ale' },
        ft = { 'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex' },
        cmd = 'ALEEnable',
        config = 'vim.cmd[[ALEEnable]]'
    }

    -- Programming Languages
    if fn.executable('rustc') then
        use {
            'simrat39/rust-tools.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
                'neovim/nvim-lspconfig'
            },
            config = function()
                require('rust-tools').setup()
            end
        }
    end

    if fn.executable('makepkg') then
        use 'm-pilia/vim-pkgbuild'
    end

    if fn.executable('meson') then
        use 'igankevich/mesonic'
    end

    if fn.executable('nix') then
        use 'LnL7/vim-nix'
        vim.g.nix_recommended_style = 0
    end

    --[[ if fn.executable('go') then
        use {
            'fatih/vim-go',
            run = ':GoUpdateBinaries'
        }
    end ]]

    if fn.executable('ansible') then
        use 'pearofducks/ansible-vim'
    end

    --use 'neoclide/jsonc.vim'

    use 'cespare/vim-toml'

    use 'gpanders/vim-scdoc'

    --use 'tylerw/zinit-vim-syntax'

    -- FZF/Skim
    if fn.executable('sk') then
        use 'lotabout/skim.vim'
    elseif fn.executable('fzf') then
        use 'junegunn/fzf.vim'
    end

    if packer_bootstrap then
        require('packer').sync()
    end
end)

cmd [[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end
]]

vim.ui.select = require"popui.ui-overrider"
vim.g.popui_border_style = "sharp"

--require('nvim-magic').setup()
