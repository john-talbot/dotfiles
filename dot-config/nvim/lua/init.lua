require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { 
        "bash",
        "bibtex",
        "c",
        "cmake",
        "cpp",
        "dockerfile",
        "doxygen",
        "latex",
        "lua",
        "make",
        "markdown",
        "pioasm",
        "python",
        "toml",
        "vim",
        "vimdoc",
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to ignore installing (or "all")
    ignore_install = { "javascript" },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        custom_captures = {
            -- Capture groups for specific elements
            ["function.call"] = "Function",
            ["method"] = "Function",
            ["method.call"] = "Function",
            ["class.method"] = "Function",
        },
    },

    indent = {
        enable = true
    },

    fold = {
        enable = true,
        disable = {},  -- List of languages you want to disable folding for
    },
}

-- Enable folding using treesitter
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

