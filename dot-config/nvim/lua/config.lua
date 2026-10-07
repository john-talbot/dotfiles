require('nvim-treesitter').install({
    "bash",
    "bibtex",
    "c",
    "cmake",
    "cpp",
    "dockerfile",
    "doxygen",
    "javascript",
    "latex",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "pioasm",
    "python",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
})

-- Highlight with tree-sitter wherever a parser is installed. LaTeX is left to
-- vimtex's syntax script, which its text objects depend on (:h vimtex-faq-treesitter).
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    if ev.match == 'tex' or ev.match == 'plaintex' then
      return
    end
    if vim.treesitter.get_parser(ev.buf, nil, { error = false }) then
      vim.treesitter.start(ev.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c","cpp","lua","python","tex","vim","vimdoc","markdown" },
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

-- Run pre-commit on the whole repo in the background and load the violations
-- into the quickfix list
local precommit_running = false

local function show_precommit_results(result, git_root)
  -- Hooks may have rewritten files on disk
  vim.cmd("checktime")

  local output = vim.split(result.stdout or "", "\n", { trimempty = true })
  local exit_code = result.code

  -- No issues
  if exit_code == 0 then
    vim.notify("No pre-commit issues found", vim.log.levels.INFO)
    return
  end

  -- Interrupted (Ctrl+C)
  if exit_code == 130 then
    vim.notify("Pre-commit was interrupted", vim.log.levels.ERROR)
    return
  end

  -- Unexpected error (exit code >= 3 and not Ctrl+C)
  if exit_code >= 3 then
    vim.notify("Pre-commit error (exit code " .. exit_code .. "):\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
    return
  end

  -- Parse and deduplicate pre-commit violations
  local filtered = {}
  local seen = {}

  for _, line in ipairs(output) do
    if line:match("^.+:%d+:%d+:") then
      local normalized = line:lower():gsub("`", "'")
      if not seen[normalized] then
        table.insert(filtered, line)
        seen[normalized] = true
      end
    end
  end

  if #filtered == 0 then
    vim.notify("Pre-commit found issues, but none matched expected format", vim.log.levels.WARN)
    return
  end

  -- Paths are relative to the repo root, not to Neovim's directory
  local abs_lines = {}
  for _, line in ipairs(filtered) do
    local path, rest = line:match("^(.-):(%d+:%d+:.*)")
    if path and path:sub(1, 1) ~= "/" then
      table.insert(abs_lines, git_root .. "/" .. path .. ":" .. rest)
    else
      table.insert(abs_lines, line)
    end
  end

  vim.fn.setqflist({}, ' ', {
    title = 'Pre-commit',
    lines = abs_lines,
    efm = '%f:%l:%c: %m,%-G%.%#',
  })
  vim.cmd("copen")
  -- Don't move the cursor out from under someone who is typing
  if vim.fn.mode() == "n" then
    vim.cmd("cc")
  end
end

vim.api.nvim_create_user_command("PrecommitQf", function()
  if precommit_running then
    vim.notify("Pre-commit is already running", vim.log.levels.WARN)
    return
  end

  local root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if root.code ~= 0 then
    vim.notify("Could not find Git root — are you in a Git repo?", vim.log.levels.ERROR)
    return
  end
  local git_root = vim.trim(root.stdout)

  precommit_running = true
  vim.notify("Running pre-commit...", vim.log.levels.INFO)
  vim.system(
    { "sh", "-c", "pre-commit run -a --color=never 2>&1" },
    { cwd = git_root, text = true },
    function(result)
      vim.schedule(function()
        precommit_running = false
        show_precommit_results(result, git_root)
      end)
    end
  )
end, {})
