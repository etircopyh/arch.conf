local enabled_linux = {
    "bash",
    "c",
    "comment",
    "cpp",
    "css",
    "go",
    "graphql",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "python",
    "regex",
    "rust",
    "scss",
    "toml",
    "tsx",
    "typescript",
    "yaml",
}

local enabled_windows = {
    "javascript",
    "lua",
}

local ensure_installed
if vim.fn.has("unix") == 1 then
    ensure_installed = enabled_linux
else
    ensure_installed = enabled_windows
end

require("nvim-treesitter.configs").setup {
    ensure_installed = ensure_installed,
    highlight = {
        enable = true,
    },
    playground = {
        enable = true,
        updatetime = 25,
        persist_queries = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<Leader>)",
            node_incremental = ")",
            node_decremental = "(",
        },
    },
}
