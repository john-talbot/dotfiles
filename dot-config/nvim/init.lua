-- MIT License
--
-- Copyright (c) [2024] [John Andrew Talbot]
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the 'Software'), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

--------------------------------------------------------------------------------
-- PACKAGE MANAGEMENT (native vim.pack)
--------------------------------------------------------------------------------
-- Hooks must be registered before the first vim.pack.add() call, since the
-- very first call can trigger install events from the lockfile.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    -- nvim-treesitter's queries only work with the parser revisions it pins, so
    -- parsers must be updated whenever the plugin is (its README's `:TSUpdate`)
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd(name)
      end
      require("nvim-treesitter").update(nil, { summary = true })
    end
    -- markdown-preview.nvim needs its server binary; install.sh downloads the
    -- prebuilt one for this plugin version, so node isn't needed at runtime
    if name == "markdown-preview.nvim" and (kind == "install" or kind == "update") then
      vim.system({ "sh", "install.sh" }, { cwd = ev.data.path .. "/app" }):wait()
    end
  end,
})

-- Plugins loaded at startup
vim.pack.add({
  -- General enhancements
  "https://github.com/tpope/vim-unimpaired",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-obsession",
  "https://github.com/echasnovski/mini.surround",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/stevearc/conform.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- { src = "https://github.com/github/copilot.vim", version = "v1.43.0" },

  -- Language server support
  "https://github.com/neovim/nvim-lspconfig",
  -- "https://github.com/williamboman/mason.nvim",
  -- "https://github.com/williamboman/mason-lspconfig.nvim",

  -- Julia support
  -- "https://github.com/JuliaEditorSupport/julia-vim",

  -- Colorschemes and statusline
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/tomasiser/vim-code-dark",

  -- LaTeX (compiling and viewing; the texlab LSP is enabled in after/plugin/lsp_init.lua)
  "https://github.com/lervag/vimtex",

  -- Markdown (rendered in-buffer, and live in a browser; marksman LSP is in lsp_init.lua)
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/iamcco/markdown-preview.nvim",
}, { confirm = false })

-- Plugins installed but not loaded at startup (equivalent to minpac's
-- {'type': 'opt'}); loaded on demand with :packadd.
vim.pack.add({
  "https://github.com/cdelledonne/vim-cmake", -- loaded by pack/personal/opt/jt-cmake
}, { load = function() end, confirm = false })

--------------------------------------------------------------------------------
-- APPEARANCE
--------------------------------------------------------------------------------
pcall(vim.cmd.colorscheme, "codedark")

-- Icons are off to avoid glyph/font problems
require("lualine").setup({
  options = {
    theme = "codedark",
    icons_enabled = false,
    section_separators = "",
    component_separators = "|",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = { "filename" },
    lualine_x = {
      function()
        if vim.bo.filetype ~= "python" then
          return ""
        end
        local venv = vim.env.VIRTUAL_ENV or vim.env.PYENV_VIRTUAL_ENV
        if not venv then
          return ""
        end
        local name = vim.fs.basename(venv)
        if name == ".venv" or name == "venv" then
          name = vim.fs.basename(vim.fs.dirname(venv))
        end
        return "(" .. name .. ")"
      end,
      "filetype",
    },
    lualine_y = {},
    lualine_z = {
      function() return vim.fn.ObsessionStatus("$$ ", "") end,
      function() return ("%3d%%"):format(math.floor(vim.fn.line(".") / vim.fn.line("$") * 100)) end,
      function() return ("Line: %d:%d"):format(vim.fn.line("."), vim.fn.virtcol(".")) end,
    },
  },
})

--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
-- Swap and undo files use Neovim's default state directory
-- (~/.local/state/nvim). Backups are kept too, but the default 'backupdir'
-- starts with "." (next to the source file), so point it at the state dir.
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup//"
vim.opt.undofile = true

-- Default to using 4 spaces per tab
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Save maximum length of 100,000 lines in terminal emulator
vim.opt.scrollback = 100000

-- Keep context around the cursor and show truncated last lines (previously
-- provided by vim-sensible)
vim.opt.scrolloff = 1
vim.opt.sidescrolloff = 2
vim.opt.display:append("truncate")
vim.opt.listchars = { tab = "> ", trail = "-", extends = ">", precedes = "<", nbsp = "+" }

-- Set column width to 88 characters
vim.opt.colorcolumn = "88"

-- Wrap text at 88 characters
-- vim.opt.textwidth = 88

-- Show line numbers
vim.opt.number = true

-- Disable mouse
vim.opt.mouse = ""

-- Split new windows below and to the right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Set insert mode completion to use fuzzy matching and only insert after
-- selection
vim.opt.completeopt:append({ "noinsert", "fuzzy" })

-- Set grep to ripgrep by default
vim.opt.grepprg = "rg --vimgrep --smart-case"

-- Code folding settings
vim.opt.foldlevel = 99 -- Open buffer with all folds expanded
vim.opt.foldnestmax = 3
vim.opt.foldminlines = 5
-- Folding by treesitter is configured per-filetype in lua/config.lua, since
-- nvim-treesitter's `main` branch dropped the `nvim_treesitter#foldexpr()`
-- function this used to reference globally (it errored with E117 on every
-- fold recompute).

--------------------------------------------------------------------------------
-- CONFIGURATION VARIABLES
--------------------------------------------------------------------------------
--- RUFF Formatting
-- Enable ruff formatting on save
vim.g.ruff_format_on_save = 1

--- LaTeX
-- View PDFs in zathura (forward and inverse SyncTeX search)
vim.g.vimtex_view_method = "zathura"
-- Match .latexmkrc: aux/log/bbl live in build/, so vimtex must look there
vim.g.vimtex_compiler_latexmk = { out_dir = "build" }

--- Markdown
-- render-markdown's defaults use Nerd Font glyphs; swap them for plain Unicode
-- (same glyph/font concern as lualine's icons_enabled = false)
local plain_link_icons = {}
for name in pairs(require("render-markdown").default.link.custom) do
  plain_link_icons[name] = { icon = "" }
end
require("render-markdown").setup({
  heading = { sign = false, icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " } },
  code = { sign = false },
  checkbox = { unchecked = { icon = "☐ " }, checked = { icon = "☑ " } },
  link = {
    image = "",
    email = "",
    hyperlink = "",
    footnote = { icon = "" },
    wiki = { icon = "" },
    custom = plain_link_icons,
  },
  callout = {
    note = { rendered = "Note" },
    tip = { rendered = "Tip" },
    important = { rendered = "Important" },
    warning = { rendered = "Warning" },
    caution = { rendered = "Caution" },
  },
})
-- Print the preview URL too, so it can be opened by hand over SSH
vim.g.mkdp_echo_preview_url = 1

--- Fuzzy Finder
-- Open fzf-lua in a bottom split window rather than a floating window
require("fzf-lua").setup({
  winopts = { split = "belowright " .. math.floor(vim.o.lines * 0.4) .. "new" },
  files = { file_icons = false, git_icons = false },
  git = { files = { file_icons = false, git_icons = false } },
})

--- Surround (vim-surround style mappings: ys, cs, ds, yss, visual S)
require("mini.surround").setup({
  mappings = {
    add = "ys",
    delete = "ds",
    find = "",
    find_left = "",
    highlight = "",
    replace = "cs",
    suffix_last = "",
    suffix_next = "",
  },
  search_method = "cover_or_next",
})
vim.keymap.del("x", "ys")
vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
vim.keymap.set("n", "yss", "ys_", { remap = true })

--------------------------------------------------------------------------------
-- KEYBINDINGS
--------------------------------------------------------------------------------
--- NORMAL MODE
-- Terminal mode exit with normal Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-v><Esc>", "<Esc>")

-- Generate Ctags easily
vim.keymap.set("n", "<Leader>t", ":GenerateCTags<CR>")

-- Toggle folds with Spacebar
vim.keymap.set("n", "<Space>", "za")

-- Close current window
vim.keymap.set("n", "<Leader>c", ":close<CR>")

-- Fuzzy-Finder
local fzf = require("fzf-lua")
vim.keymap.set("n", "<Leader>ff", fzf.files)
vim.keymap.set("n", "<Leader>fd", function() fzf.files({ cwd = vim.fn.expand("%:p:h") }) end)
vim.keymap.set("n", "<Leader>fa", ":AllFiles<CR>")
vim.keymap.set("n", "<Leader>fg", fzf.git_files)
vim.keymap.set("n", "<Leader>fb", fzf.buffers)
vim.keymap.set("n", "<Leader>ft", fzf.tags)
vim.keymap.set("n", "<Leader>fm", fzf.marks)
vim.keymap.set("n", "<Leader>fc", fzf.commands)
vim.keymap.set("n", "<Leader>fh", fzf.command_history)
vim.keymap.set("n", "<Leader>fs", fzf.search_history)

-- Pre-commit to quickfix - function in lua/config.lua
vim.keymap.set("n", "<Leader>qf", ":PrecommitQf<CR>")

--------------------------------------------------------------------------------
-- COMMANDS
--------------------------------------------------------------------------------
-- Automatically open quickfix window after running a quickfix command
vim.api.nvim_create_augroup("JTQuickFixGroup", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = "JTQuickFixGroup",
  pattern = "[^l]*",
  nested = true,
  command = "cwindow",
})

-- Set visual to use current nvim session
if vim.fn.executable("nvr") == 1 then
  vim.env.VISUAL = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
end

-- Fuzzy Finder custom command to search files including gitignored files
local function get_rg_source()
  local exclude_patterns = {
    "!**/install/**/*",
    "!**/log/**/*",
    "!**/build*/**/*",
    "!**/external/**/*",
    "!**/doc/**/*",
    "!**/*.pyc",
  }
  local globs = {}
  for _, pattern in ipairs(exclude_patterns) do
    table.insert(globs, "-g " .. pattern)
  end
  return "rg --files -u " .. table.concat(globs, " ")
end

vim.api.nvim_create_user_command("AllFiles", function()
  require("fzf-lua").files({ cmd = get_rg_source(), file_icons = false, git_icons = false })
end, {})

--------------------------------------------------------------------------------
-- LUA INIT
--------------------------------------------------------------------------------
-- Extra lua initialization for neovim (located at .config/nvim/lua/config.lua)
require("config")
require("formatting")
