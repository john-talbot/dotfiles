-- Load rust-analyzer (global plugin setup)
require("lspconfig").rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
        },
    },
})
