-- JS/TS are intentionally absent: they format via the biome LSP client in
-- after/ftplugin/{javascript,typescript}/.
local toggles = {
  python = "ruff_format_on_save",
  cpp = "clang_format_on_save",
  markdown = "prettier_format_on_save",
}

local function is_off(value)
  return value == 0 or value == false
end

require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_organize_imports", "ruff_format" },
    cpp = { "clang-format" },
    markdown = { "prettier" },
  },
  format_on_save = function(bufnr)
    local flag = toggles[vim.bo[bufnr].filetype]
    if flag and (is_off(vim.g[flag]) or is_off(vim.b[bufnr][flag])) then
      return
    end
    return { timeout_ms = 2000, lsp_format = "never" }
  end,
})
