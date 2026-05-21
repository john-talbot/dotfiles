-- Rust
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})

-- JS/TS
local js_ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

vim.lsp.config("ts_ls", { filetypes = js_ts_filetypes })
vim.lsp.config("biome", { filetypes = js_ts_filetypes })

-- Python (add if you want it; remove if not)
vim.lsp.config("pyright", {})
vim.lsp.config("ruff", {})

vim.lsp.enable({ "rust_analyzer", "ts_ls", "biome", "pyright", "ruff" })

-- Keymaps on ts_ls attach (unchanged)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- if client.name ~= "ts_ls" then return end
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  end,
})

-- Quickfix on diagnostics for JS/TS (unchanged)
local js_ts_ft_set = {}
for _, ft in ipairs(js_ts_filetypes) do js_ts_ft_set[ft] = true end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function(args)
    if not js_ts_ft_set[vim.bo[args.buf].filetype] then return end
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
