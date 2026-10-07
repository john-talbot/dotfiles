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

-- clangd needs compile_commands.json; vim-cmake links it (see jt-cmake).
-- texlab only provides language features; vimtex compiles and views LaTeX.
vim.lsp.enable({ "rust_analyzer", "ts_ls", "biome", "pyright", "ruff", "clangd", "texlab", "marksman" })

-- Native LSP completion. autotrigger only fires on a server's own trigger
-- characters (e.g. "."), so also trigger on letters to get as-you-type
-- completion (see :help lsp-autocompletion). Accept an item with CTRL-Y.
vim.opt.completeopt:append("menuone")
local letters = {}
for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do
  table.insert(letters, c)
end
local extended_clients = {}

-- Completion and keymaps on LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- Let pyright own hover (ruff's docs recommend this when pairing them)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    if client and client:supports_method("textDocument/completion") then
      local provider = client.server_capabilities.completionProvider
      if provider and not extended_clients[client.id] then
        provider.triggerCharacters = vim.list_extend(provider.triggerCharacters or {}, letters)
        extended_clients[client.id] = true
      end
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
    -- Format on save with biome, once per buffer, only while biome is attached
    if client and client.name == "biome" then
      local group = vim.api.nvim_create_augroup("biome_format_" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, name = "biome" })
        end,
      })
    end
    -- K (hover) and grr/gra/grn/gri are Neovim's own LSP defaults
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    -- Both open their list. The location list is window-local, so it never
    -- overwrites :grep, :make or PrecommitQf results the way the quickfix list does.
    vim.keymap.set("n", "<leader>dq", function()
      vim.diagnostic.setqflist()
    end, { buffer = ev.buf, desc = "Diagnostics → quickfix (all buffers)" })
    vim.keymap.set("n", "<leader>dl", function()
      vim.diagnostic.setloclist()
    end, { buffer = ev.buf, desc = "Diagnostics → location list (buffer)" })
  end,
})

-- JS/TS editor settings: 2-space indent and biome/prettier's 80-column ruler
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("js_ts_settings", { clear = true }),
  pattern = js_ts_filetypes,
  callback = function(ev)
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "80"
  end,
})

-- Keep a location list of diagnostics open for JS/TS windows. It is window-local,
-- so unlike the quickfix list it never overwrites :grep, :make or PrecommitQf.
local js_ts_ft_set = {}
for _, ft in ipairs(js_ts_filetypes) do js_ts_ft_set[ft] = true end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function(args)
    if not js_ts_ft_set[vim.bo[args.buf].filetype] then return end
    -- Deferred because this can fire where changing windows is not allowed
    -- (e.g. while a buffer is being reloaded), which raises E565
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      local current = vim.api.nvim_get_current_win()
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        vim.diagnostic.setloclist({ winnr = win, open = false })
        vim.api.nvim_win_call(win, function()
          if #vim.fn.getloclist(win) > 0 then
            vim.cmd("lopen")
          else
            pcall(vim.cmd, "lclose")
          end
        end)
      end
      if vim.api.nvim_win_is_valid(current) then
        vim.api.nvim_set_current_win(current)
      end
    end)
  end,
})
