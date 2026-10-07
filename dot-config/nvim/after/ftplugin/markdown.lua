-- In-buffer rendering is on by default; the browser preview follows the cursor
vim.keymap.set("n", "<Leader>mr", "<Cmd>RenderMarkdown buf_toggle<CR>",
  { buffer = true, desc = "Toggle in-buffer Markdown rendering" })
vim.keymap.set("n", "<Leader>mp", "<Cmd>MarkdownPreviewToggle<CR>",
  { buffer = true, desc = "Toggle browser Markdown preview" })
