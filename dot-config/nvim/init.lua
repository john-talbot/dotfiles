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
    if name == "markdown-preview.nvim" and (kind == "install" or kind == "update") then
      vim.cmd.packadd(name)
      vim.fn["mkdp#util#install"]()
    end
  end,
})

-- Plugins loaded at startup
vim.pack.add({
  -- General enhancements
  "https://github.com/tpope/vim-sensible",
  "https://github.com/tpope/vim-surround",
  "https://github.com/tpope/vim-unimpaired",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-commentary",
  "https://github.com/tpope/vim-obsession",
  "https://github.com/junegunn/fzf",
  "https://github.com/junegunn/fzf.vim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- { src = "https://github.com/github/copilot.vim", version = "v1.43.0" },

  -- Language server support
  "https://github.com/neovim/nvim-lspconfig",
  -- "https://github.com/williamboman/mason.nvim",
  -- "https://github.com/williamboman/mason-lspconfig.nvim",

  -- Julia support
  -- "https://github.com/JuliaEditorSupport/julia-vim",

  -- Colorschemes
  "https://github.com/vim-airline/vim-airline",
  "https://github.com/tomasiser/vim-code-dark",

  -- Unicode support
  "https://github.com/arthurxavierx/vim-unicoder",
}, { confirm = false })

-- Plugins installed but not loaded at startup (equivalent to minpac's
-- {'type': 'opt'}); loaded on demand with :packadd.
vim.pack.add({
  "https://github.com/cdelledonne/vim-cmake", -- loaded by pack/personal/opt/jt-cmake
  "https://github.com/iamcco/markdown-preview.nvim", -- :packadd markdown-preview.nvim
}, { load = function() end, confirm = false })

-- Add matchit plugin
vim.cmd("packadd! matchit")

--------------------------------------------------------------------------------
-- APPEARANCE
--------------------------------------------------------------------------------
pcall(vim.cmd.colorscheme, "codedark")

-- Load desired airline extensions
vim.g.airline_extensions = { "branch", "virtualenv" }

-- Remove encoding section of airline
vim.g.airline_section_y = ""

-- Fix font problems by removing glyphs from airline symbols
-- vim.g getters return a copy, so mutate a local table and reassign it
-- whole, rather than assigning into vim.g.airline_symbols fields directly.
local airline_symbols = vim.g.airline_symbols or {}
airline_symbols.colnr = " Col: "
airline_symbols.linenr = " Line: "
airline_symbols.maxlinenr = " "
vim.g.airline_symbols = airline_symbols

-- Add vim-obsession to airline
function AirlineInit()
  vim.g.airline_section_z = vim.fn["airline#section#create"]({
    "%{ObsessionStatus('$$ ', '')}",
    "windowswap",
    "%3p%% ",
    "linenr",
    ":%3v ",
  })
end
vim.api.nvim_create_autocmd("User", {
  pattern = "AirlineAfterInit",
  callback = AirlineInit,
})

--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
-- Enable swap files and set directory
vim.opt.directory:prepend(vim.fn.expand("~/.config/nvim/swap//"))
vim.opt.swapfile = true

-- Enable backup files and set directory
vim.opt.backup = true
vim.opt.backupdir:prepend(vim.fn.expand("~/.config/nvim/backup//"))

-- Enable persistent undo and set directory
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undo//")

-- Default to using 4 spaces per tab
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Save last 2000 commands in history rather than 20
vim.opt.history = 2000

-- Save maximum length of 100,000 lines in terminal emulator
vim.opt.scrollback = 100000

-- Configure wildmenu to behave like zsh
vim.opt.wildmenu = true
vim.opt.wildmode = "full"

-- Enable filetype recognition and load relevant plugin
vim.cmd("filetype plugin indent on")

-- Set column width to 88 characters
vim.opt.colorcolumn = "88"

-- Wrap text at 88 characters
-- vim.opt.textwidth = 88

-- Show line numbers
vim.opt.number = true

-- Set incremental search and highlight search results
vim.opt.incsearch = true
vim.opt.hlsearch = true

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

--- Fuzzy Finder
-- Pop up fzf-vim in a bottom split window
vim.g.fzf_layout = { down = "~40%" }

--------------------------------------------------------------------------------
-- KEYBINDINGS
--------------------------------------------------------------------------------
--- NORMAL MODE
-- Keybind Ctrl-l to call nohlsearch as well as redraw screen
vim.keymap.set("n", "<C-l>", ":<C-u>nohlsearch<CR><C-l>", { silent = true })

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
vim.keymap.set("n", "<Leader>ff", ":Files<CR>")
vim.keymap.set("n", "<Leader>fd", ":Files %:p:h<CR>")
vim.keymap.set("n", "<Leader>fa", ":AllFiles<CR>")
vim.keymap.set("n", "<Leader>fg", ":GFiles<CR>")
vim.keymap.set("n", "<Leader>fb", ":Buffers<CR>")
vim.keymap.set("n", "<Leader>ft", ":Tags<CR>")
vim.keymap.set("n", "<Leader>fm", ":Marks<CR>")
vim.keymap.set("n", "<Leader>fc", ":Commands<CR>")
vim.keymap.set("n", "<Leader>fh", ":History:<CR>")
vim.keymap.set("n", "<Leader>fs", ":History/<CR>")

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

vim.api.nvim_create_user_command("AllFiles", function(opts)
  vim.fn["fzf#vim#files"]("", vim.fn["fzf#vim#with_preview"]({ source = get_rg_source() }), opts.bang)
end, { bang = true, nargs = "*" })

--------------------------------------------------------------------------------
-- LUA INIT
--------------------------------------------------------------------------------
-- Extra lua initialization for neovim (located at .config/nvim/lua/config.lua)
require("config")
