-- 2-space indent (biome/prettier default for TS)
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

-- Ruler at biome's default line length
vim.opt_local.colorcolumn = "80"

-- Auto-format on save using biome
vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = 0,
    callback = function()
        vim.lsp.buf.format({ name = "biome", async = false })
    end,
})

-- Manual quickfix refresh
vim.keymap.set("n", "<leader>dq", function()
    vim.diagnostic.setqflist()
    vim.cmd("copen")
end, { buffer = true, desc = "Diagnostics → quickfix list" })
