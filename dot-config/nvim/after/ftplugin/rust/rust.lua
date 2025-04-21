-- Auto-format Rust files on save
vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = 0,
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- Set up LSP keymaps once rust-analyzer attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client.name ~= "rust_analyzer" then return end

        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})

-- Auto-update and manage quickfix list when diagnostics change
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args)
        local bufnr = args.buf
        if vim.bo[bufnr].filetype ~= "rust" then return end

        vim.diagnostic.setqflist({ open = false })
        local qf = vim.fn.getqflist()

        if #qf > 0 then
            local win = vim.api.nvim_get_current_win()
            vim.cmd("copen")
            vim.api.nvim_set_current_win(win)
        else
            vim.cmd("cclose")
        end
    end,
})

-- Optional: manual quickfix refresh & open
vim.keymap.set("n", "<leader>dq", function()
    vim.diagnostic.setqflist()
    vim.cmd("copen")
end, { buffer = true, desc = "Diagnostics → quickfix list" })
