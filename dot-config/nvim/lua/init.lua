require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
    custom_captures = {
      -- Capture groups for specific elements
      ["function.call"] = "Function",
      ["method"] = "Function",
      ["method.call"] = "Function",
      ["class.method"] = "Function",
      -- Add more as needed
    },
  },
}

-- These are LSP for python. When I tried them in 2024 they were way too busy.
-- Maybe they'll be more usable in the future.

-- require("mason").setup {}
-- require("mason-lspconfig").setup { ensure_installed = { "pyright", "basedpyright" }, }
-- require 'lspconfig'.pyright.setup {}
-- require 'lspconfig'.basedpyright.setup { typeCheckingMode = "off" }
