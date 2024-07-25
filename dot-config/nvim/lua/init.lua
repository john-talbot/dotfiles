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
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",    -- Initialize selection
            node_incremental = "grn",  -- Increment to the upper named parent
            scope_incremental = "grc", -- Increment to the upper scope (as defined in locals.scm)
            node_decremental = "grm",  -- Decrement to the previous node
        },
    },

    indent = {
        enable = false,
    },

    fold = {
        enable = true,
    },
}
