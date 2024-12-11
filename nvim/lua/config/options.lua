vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable LazyVim auto format
vim.g.autoformat = false

local opt = vim.opt

--
-- System
--
opt.autochdir = true
opt.clipboard = "unnamedplus"

--
-- basic init
--
opt.number = true
opt.relativenumber = true
opt.list = true
opt.hidden = true
opt.textwidth = 0
opt.showmode = false
opt.ttyfast = true
opt.lazyredraw = true

opt.confirm = true -- Confirm to save changes before exiting modified buffer

-- instead of bell when error
opt.visualbell = true
opt.showcmd = true
opt.wildmenu = true
opt.virtualedit = "block"

-- highlight current line
opt.cursorline = true

-- Use the pretty colors
opt.termguicolors = true

opt.shiftround = true
opt.updatetime = 100
opt.autowrite = true

opt.foldlevel = 99
opt.foldenable = false

opt.statuscolumn = [[%!v:lua.require'util'.ui.statuscolumn()]]

opt.smoothscroll = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""

-- format
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Ignore the case when the search pattern is all lowercase
opt.smartcase = true
opt.ignorecase = true

-- Keep lines below cursor when scrolling
opt.scrolloff = 5
opt.sidescrolloff = 5

-- Always display signcolumn (for diagnostic related stuff)
opt.signcolumn = "yes"

-- When opening a window put it right or below the current one
opt.splitright = true
opt.splitbelow = true

-- Enable mouse support
opt.mouse = "a"

-- Insert mode completion setting
opt.completeopt = { "menu", "menuone", "longest", "noinsert", "noselect", "preview" }

-- Set grep default grep command with ripgrep
opt.grepprg = "rg --vimgrep --follow"
opt.errorformat:append("%f:%l:%c%p%m")

--
-- tabs
--
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autowrite = false

opt.autoindent = true
opt.smartindent = true

-- Disable line wrapping
opt.wrap = true

opt.ttimeoutlen = 300

-- set undo and backup path
opt.undofile = true
opt.undolevels = 5000
opt.undodir = vim.fn.stdpath("config") .. "/.tmp/undo//"
opt.directory = vim.fn.stdpath("config") .. "/.tmp/swap//"
opt.backupdir = vim.fn.stdpath("config") .. "/.tmp/backup//"
