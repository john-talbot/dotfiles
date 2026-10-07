-- :GenerateCTags runs ctags asynchronously from the git root (or the current
-- directory outside a repo). Override with g:ctags_arguments / g:ctags_paths.
local function git_root(path)
  local result = vim.system({ "git", "-C", path, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code == 0 then
    return vim.trim(result.stdout)
  end
end

local function root_path()
  local not_file_buffer = (vim.fn.line("$") == 1 and vim.fn.getline(1) == "") or vim.fn.expand("%") == ""
  local base = not_file_buffer and vim.fn.getcwd() or vim.fn.expand("%:p:h")
  return git_root(base) or base
end

vim.api.nvim_create_user_command("GenerateCTags", function()
  local root = root_path()
  local args = vim.g.ctags_arguments or { "-R", "-f", root .. "/tags" }

  local paths = { root }
  for _, path in ipairs(vim.g.ctags_paths or {}) do
    if path ~= root then
      table.insert(paths, path)
    end
  end

  local cmd = vim.list_extend(vim.list_extend({ "ctags" }, args), paths)
  vim.notify("Generating CTags in " .. root .. "...")

  local ok, err = pcall(vim.system, cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("CTags done")
      else
        vim.notify("ctags failed (exit " .. result.code .. "): " .. (result.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
  if not ok then
    vim.notify("Could not run ctags: " .. tostring(err), vim.log.levels.ERROR)
  end
end, {})
