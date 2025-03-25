require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { 
        "bash",
        "bibtex",
        "c",
        "cmake",
        "cpp",
        "dockerfile",
        "doxygen",
        "latex",
        "lua",
        "make",
        "markdown",
        "pioasm",
        "python",
        "toml",
        "vim",
        "vimdoc",
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to ignore installing (or "all")
    ignore_install = { "javascript" },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        custom_captures = {
            -- Capture groups for specific elements
            ["function.call"] = "Function",
            ["method"] = "Function",
            ["method.call"] = "Function",
            ["class.method"] = "Function",
        },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",    -- Initialize selection
            node_incremental = "grn",  -- Increment to the upper named parent
            scope_incremental = "grc", -- Increment to the upper scope (as defined in locals.scm)
            node_decremental = "grm",  -- Decrement to the previous node
        },
    },

    indent = {
        enable = false,
    },

    fold = {
        enable = true,
    },
}

-- Command to run pre-commit and load results into quickfix list
vim.api.nvim_create_user_command("PrecommitQf", function()
  -- Detect Git root
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then
    vim.notify("Could not find Git root — are you in a Git repo?", vim.log.levels.ERROR)
    return
  end

  -- Save current working directory
  local original_cwd = vim.fn.getcwd()

  -- Change to Git root for consistent path resolution
  vim.cmd("cd " .. vim.fn.fnameescape(git_root))

  -- Run pre-commit from repo root
  local cmd = "pre-commit run -a --color=never 2>&1"
  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  -- Restore working directory
  vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))

  -- ✅ Early return if nothing was detected
  if exit_code == 0 then
    vim.notify("No pre-commit issues found", vim.log.levels.INFO)
    return
  end

  -- 🛑 Pre-commit was interrupted (Ctrl+C)
  if exit_code == 130 then
    vim.notify("Pre-commit was interrupted", vim.log.levels.ERROR)
    return
  end

  -- ❌ Unexpected error (exit code >= 3 and not Ctrl+C)
  if exit_code >= 3 then
    vim.notify("Pre-commit error (exit code " .. exit_code .. "):\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
    return
  end

  -- ⚠️ Parse and deduplicate pre-commit violations
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

  if #filtered > 0 then
    -- Make paths absolute by prepending git_root
    local abs_lines = {}
    for _, line in ipairs(filtered) do
      local path, rest = line:match("^(.-):(%d+:%d+:.*)")
      if path then
        table.insert(abs_lines, git_root .. "/" .. path .. ":" .. rest)
      else
        table.insert(abs_lines, line)
      end
    end

    vim.fn.setqflist({}, ' ', {
      title = 'Pre-commit',
      lines = abs_lines,
    })
    vim.cmd("copen")
    vim.cmd("cc")
  else
    vim.notify("Pre-commit found issues, but none matched expected format", vim.log.levels.WARN)
  end
end, {})
