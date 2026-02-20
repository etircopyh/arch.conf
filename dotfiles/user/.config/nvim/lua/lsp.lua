Prequire = function(module)
    local ok, mod = pcall(require, module)
    return ok, mod
end

local luasnip   = require('luasnip')
local lspconfig = require('lspconfig')
local lspkind   = require 'lspkind'
local cmp       = require('cmp')
local lint      = require('lint')
local command   = vim.api.nvim_add_user_command

local map = vim.keymap.set

local _, types = Prequire('cmp.types')
local _, str   = Prequire('cmp.utils.str')

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local on_attach = function()
    local opts = { noremap = true, silent = true, buffer = true }
    map('n', 'gD', function() return vim.lsp.buf.declaration() end, opts)
    map('n', 'gd', function() return vim.lsp.buf.definition() end, opts)
    map('n', 'K', function() return vim.lsp.buf.hover() end, opts)
    map('n', 'gi', function() return vim.lsp.buf.implementation() end, opts)
    map('n', '<C-k>', function() return vim.lsp.buf.signature_help() end, opts)
    map('n', '<leader>wa', function() return vim.lsp.buf.add_workspace_folder() end, opts)
    map('n', '<leader>wr', function() return vim.lsp.buf.remove_workspace_folder() end, opts)
    map('n', '<leader>wl', function() return print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    map('n', '<leader>D', function() return vim.lsp.buf.type_definition() end, opts)
    map('n', '<leader>rn', function() return vim.lsp.buf.rename() end, opts)
    map('n', 'gr', function() return vim.lsp.buf.references() end, opts)
    map('n', '<leader>ca', function() return vim.lsp.buf.code_action() end, opts)
    map('n', '<leader>so', function() return require('telescope.builtin').lsp_document_symbols() end, opts)
    command('Format', function() return vim.lsp.buf.formatting() end, { bang = true })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local servers = { 'yamlls', 'vimls', 'html', 'rnix', 'jsonls', 'cssls', 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach    = on_attach,
        capabilities = capabilities,
    }
end


local function is_nixos()
    local nixossystem = io.popen('cat /etc/os-release'):read()
    if nixossystem:find('NixOS') then
        return true
    end
end

if is_nixos() then
    sumneko_root_path = '/nix/store/iqydi7781amrpc678y5nr3nxd7g7hqgw-sumneko-lua-language-server-2.3.6/extras'
    sumneko_binary    = sumneko_root_path .. '/bin/lua-language-server'
else
    sumneko_root_path = '/usr/share/lua-language-server'
    sumneko_binary    = '/usr/bin/lua-language-server'
end

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    cmd = { sumneko_binary, '-E', sumneko_root_path .. '/main.lua' };
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path    = runtime_path,
            },
            diagnostics = {
                globals = { 'vim' }
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            },
            telemetry = {
                enable = false
            },
        },
    },
}

cmp.setup {
    documentation = true,

    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    completion = { border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }, scrollbar = '║' },
    window = {
        documentation = {
            border    = 'rounded',
            scrollbar = '║',
        },
        completion = {
            border    = 'rounded',
            scrollbar = '║',
        },
    },

    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end,
    },

    formatting = {
        fields = {
            cmp.ItemField.Kind,
            cmp.ItemField.Abbr,
            cmp.ItemField.Menu,
        },
        format = lspkind.cmp_format({
            mode = 'symbol',
            with_text = false,
            before    = function(entry, vim_item)
                -- Get the full snippet (and only keep first line)
                local word = entry:get_insert_text()
                if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
                    word = vim.lsp.util.parse_snippet(word)
                end
                word = str.oneline(word)


                if
                    entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
                    and string.sub(vim_item.abbr, -1, -1) == '~'
                    then
                        word = word .. '~'
                    end
                    vim_item.abbr = word

                    return vim_item
                end
        }),
    },

    sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'nvim_lua' },
        { name = 'crates' },
        { name = 'git' },
    }, {
        { name = 'buffer' },
    },
}

cmp.setup.cmdline('/', {
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})



lspconfig.bashls.setup {
    on_attach    = on_attach,
    capabilities = capabilities,
    filetypes    = { 'bash', 'sh', 'zsh' }
}


--lspconfig.ccls.setup {
--    on_attach    = on_attach,
--    capabilities = capabilities,
--    init_options = {
--        compilationDatabaseDirectory = 'build';
--        highlight = { lsRanges = true; };
--        cache  = { directory = vim.fn.expand('$XDG_STATE_HOME/LSP/ccls-cache'); };
--        index  = { threads = 0; };
--        clang  = { excludeArgs = { '-frounding-math' }; };
--        client = { snippetSupport = true; };
--    }
--}

lspconfig.gopls.setup {
    on_attach    = on_attach,
    capabilities = capabilities,
    init_options = {
        usePlaceholders    = true;
        completeUnimported = true;
    },
}


lint.linters_by_ft = {
    markdown = { 'vale' },
    nix      = { 'nix' },
    bash     = { 'shellcheck' },
    lua      = { 'luacheck' },
    cpp      = { 'cppcheck' },
    qt       = { 'clazy' },
    yaml     = { 'yamllint' },
    text     = { 'codespell' }
}

vim.cmd [[autocmd BufWritePost <buffer> lua require('lint').try_lint()]]

--vim.lsp.handlers['textDocument/codeAction']     = require('lsputil.codeAction').code_action_handler
--vim.lsp.handlers['textDocument/references']     = require('lsputil.locations').references_handler
--vim.lsp.handlers['textDocument/definition']     = require('lsputil.locations').definition_handler
--vim.lsp.handlers['textDocument/declaration']    = require('lsputil.locations').declaration_handler
--vim.lsp.handlers['textDocument/typeDefinition'] = require('lsputil.locations').typeDefinition_handler
--vim.lsp.handlers['textDocument/implementation'] = require('lsputil.locations').implementation_handler
--vim.lsp.handlers['textDocument/documentSymbol'] = require('lsputil.symbols').document_handler
--vim.lsp.handlers['workspace/symbol']            = require('lsputil.symbols').workspace_handler

--local function map(mode, lhs, rhs, opts)
--  local options = { noremap = true }
--  if opts then options = vim.tbl_extend('force', options, opts) end
--  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
--end
