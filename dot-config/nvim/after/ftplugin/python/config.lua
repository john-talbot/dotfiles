vim.cmd.compiler("ruff")

vim.api.nvim_buf_create_user_command(0, "RuffFormat", function()
  require("conform").format({
    formatters = { "ruff_organize_imports", "ruff_format" },
    lsp_format = "never",
    timeout_ms = 2000,
  })
end, {})

vim.keymap.set("n", "<Leader>r", "<Cmd>RuffFormat<CR>", { buffer = true })
