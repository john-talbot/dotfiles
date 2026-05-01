-- Load rust-analyzer (global plugin setup)
require("lspconfig").rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
        },
    },
})

-- JavaScript / TypeScript: ts_ls for intellisense, biome for formatting + linting
local js_ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

require("lspconfig").ts_ls.setup({
    filetypes = js_ts_filetypes,
})

require("lspconfig").biome.setup({
    filetypes = js_ts_filetypes,
})

-- Set up LSP keymaps once ts_ls attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client.name ~= "ts_ls" then return end

        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})

-- Auto-update and manage quickfix list when diagnostics change in JS/TS files
local js_ts_ft_set = {}
for _, ft in ipairs(js_ts_filetypes) do js_ts_ft_set[ft] = true end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args)
        local bufnr = args.buf
        if not js_ts_ft_set[vim.bo[bufnr].filetype] then return end

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
